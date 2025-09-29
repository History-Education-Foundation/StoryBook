from langchain_openai import ChatOpenAI
from langchain_core.tools import tool
from dotenv import load_dotenv
load_dotenv()

from langgraph.graph import MessagesState
from langchain_core.messages import HumanMessage, SystemMessage, AIMessage
from typing import Annotated

from langgraph.graph import START, StateGraph
from langgraph.prebuilt import tools_condition, ToolNode, InjectedState
from langgraph.prebuilt.chat_agent_executor import AgentState


import asyncio
from pathlib import Path
import os
import logging

from openai import OpenAI
from app.agents.utils.images import encode_image

# Define base paths relative to project root
SCRIPT_DIR = Path(__file__).parent.resolve()
PROJECT_ROOT = SCRIPT_DIR.parent.parent.parent  # Go up to LlamaBot root
APP_DIR = PROJECT_ROOT / 'app'

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# System message
sys_msg = "You are a helpful assistant. Your favorite animal is cyborg llama."
# Warning: Brittle - None type will break this when it's injected into the state for the tool call, and it silently fails. So if it doesn't map state types properly from the frontend, it will break. (must be exactly what's defined here).
class LlamaPressState(AgentState): 
    api_token: str
    agent_prompt: str

@tool
async def read_book(
    state: Annotated[dict, InjectedState],
) -> str:
    """
    Read the contents of a book, give back a summary of the book.
    """
    logger.info("Reading book!")

    api_token = state.get("api_token")
    if not api_token:
        return "Error: api_token is required but not provided in state."

    result = await make_api_request_to_llamapress(
        method="GET",
        endpoint="/books.JSON",
        api_token=api_token
    )

    if isinstance(result, str):
        return result

    return {'toolname': 'read_book', 'tool args': {}, "tool_output": result}

# Global tools list
tools = [read_book]

# Node
def leo(state: LlamaPressState):
   breakpoint() # add this line to test if this is being loaded correctly, and that we hit the breakpoint.
   llm = ChatOpenAI(model="gpt-4.1")
   llm_with_tools = llm.bind_tools(tools)

   custom_prompt_instructions_from_llamapress_dev = state.get("agent_prompt")
   full_sys_msg = SystemMessage(content=f"""{sys_msg} Here are additional instructions provided by the developer: <DEVELOPER_INSTRUCTIONS> {custom_prompt_instructions_from_llamapress_dev} </DEVELOPER_INSTRUCTIONS>""")

   return {"messages": [llm_with_tools.invoke([full_sys_msg] + state["messages"])]}

def build_workflow(checkpointer=None):
    # Graph
    builder = StateGraph(LlamaPressState)

    # Define nodes: these do the work
    builder.add_node("leo", leo)
    builder.add_node("tools", ToolNode(tools))

    # Define edges: these determine how the control flow moves
    builder.add_edge(START, "leo")
    builder.add_conditional_edges(
        "leo",
        # If the latest message (result) from leo is a tool call -> tools_condition routes to tools
        # If the latest message (result) from leo is a not a tool call -> tools_condition routes to END
        tools_condition,
    )
    builder.add_edge("tools", "leo")
    react_graph = builder.compile(checkpointer=checkpointer)

    return react_graph