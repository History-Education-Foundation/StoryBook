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
import os

from openai import OpenAI
from app.agents.utils.images import encode_image
from app.agents.utils.make_api_request_to_llamapress import make_api_request_to_llamapress

# Define base paths relative to project root
SCRIPT_DIR = Path(__file__).parent.resolve()
PROJECT_ROOT = SCRIPT_DIR.parent.parent.parent  # Go up to LlamaBot root
APP_DIR = PROJECT_ROOT / 'app'

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# System message
sys_msg = """You are a helpful assistant. Your favorite animal is cyborg llama.

You have access to a powerful set of tools to create and manage children's storybooks in a Rails application.
When a user asks you to write a story, you must follow this exact workflow:
1.  **Create the Book:** Use the `create_book` tool. You will need to ask the user for the title, learning outcome, and reading level.
2.  **Get the Book ID:** The `create_book` tool will return a book object. You MUST extract the `id` from this object to use in the next steps.
3.  **Create Chapters:** For each chapter in the story, use the `create_chapter` tool. You will need the `book_id` from the previous step.
4.  **Get Chapter IDs:** The `create_chapter` tool will return a chapter object. You MUST extract the `id` for each chapter.
5.  **Create Pages:** For each page within a chapter, use the `create_page` tool. You will need both the `book_id` and the `chapter_id`.
6.  **Generate Images (Optional):** After creating a page, you can use the `generate_page_image` tool to create an illustration for it. The user may ask for this.

Always confirm with the user before creating content, and remember to extract the IDs from the results of the `create` tools to use them in subsequent steps.
"""
# Warning: Brittle - None type will break this when it's injected into the state for the tool call, and it silently fails. So if it doesn't map state types properly from the frontend, it will break. (must be exactly what's defined here).

class LlamaPressState(AgentState):
    api_token: str
    agent_prompt: str


@tool
async def list_books(
    state: Annotated[dict, InjectedState],
) -> str:
    """
    Lists all available published books that can be read.
    """
    logger.info("Listing books!")
    #breakpoint()
    api_token = state.get("api_token")
    if not api_token:
        return "Error: api_token is required but not provided in state."

    result = await make_api_request_to_llamapress(
        method="GET",
        endpoint="/books.json",
        api_token=api_token
    )

    if isinstance(result, str):
        return result

    return {'toolname': 'list_books', 'tool args': {}, "tool_output": result}


@tool
async def create_book(
    state: Annotated[dict, InjectedState],
    title: str,
    learning_outcome: str,
    reading_level: str,
) -> str:
    """
    Creates a new book with the given title, learning outcome, and reading level.
    Returns the created book object, including its ID.
    """
    logger.info(f"Creating book with title: {title}")

    api_token = state.get("api_token")
    if not api_token:
        return "Error: api_token is required but not provided in state."

    book_data = {
        "book": {
            "title": title,
            "learning_outcome": learning_outcome,
            "reading_level": reading_level,
        }
    }

    result = await make_api_request_to_llamapress(
        method="POST",
        endpoint="/books.json",
        api_token=api_token,
        data=book_data,
    )

    if isinstance(result, str):
        return result

    return {'toolname': 'create_book', 'tool args': {'title': title}, "tool_output": result}


@tool
async def create_chapter(
    state: Annotated[dict, InjectedState],
    book_id: int,
    title: str,
    description: str,
) -> str:
    """
    Creates a new chapter for a given book.
    Requires the book_id.
    Returns the created chapter object, including its ID.
    """
    logger.info(f"Creating chapter for book {book_id} with title: {title}")

    api_token = state.get("api_token")
    if not api_token:
        return "Error: api_token is required but not provided in state."

    chapter_data = {
        "chapter": {
            "title": title,
            "description": description,
        }
    }

    result = await make_api_request_to_llamapress(
        method="POST",
        endpoint=f"/books/{book_id}/chapters.json",
        api_token=api_token,
        data=chapter_data,
    )

    if isinstance(result, str):
        return result

    return {'toolname': 'create_chapter', 'tool args': {'book_id': book_id, 'title': title}, "tool_output": result}


@tool
async def create_page(
    state: Annotated[dict, InjectedState],
    book_id: int,
    chapter_id: int,
    content: str,
) -> str:
    """
    Creates a new page within a given chapter.
    Requires book_id and chapter_id.
    Returns the created page object.
    """
    logger.info(f"Creating page for chapter {chapter_id}")

    api_token = state.get("api_token")
    if not api_token:
        return "Error: api_token is required but not provided in state."

    page_data = {"page": {"content": content}}

    result = await make_api_request_to_llamapress(
        method="POST",
        endpoint=f"/books/{book_id}/chapters/{chapter_id}/pages.json",
        api_token=api_token,
        data=page_data,
    )

    if isinstance(result, str):
        return result

    return {'toolname': 'create_page', 'tool args': {'chapter_id': chapter_id}, "tool_output": result}


@tool
async def generate_page_image(
    state: Annotated[dict, InjectedState],
    book_id: int,
    chapter_id: int,
    page_id: int,
) -> str:
    """
    Generates an image for a specific page based on its content and the book's context.
    Requires book_id, chapter_id, and page_id.
    """
    logger.info(f"Generating image for page {page_id}")

    api_token = state.get("api_token")
    if not api_token:
        return "Error: api_token is required but not provided in state."

    result = await make_api_request_to_llamapress(
        method="POST",
        endpoint=f"/books/{book_id}/chapters/{chapter_id}/pages/{page_id}/generate_image.json",
        api_token=api_token,
    )

    if isinstance(result, str):
        return result

    return {'toolname': 'generate_page_image', 'tool args': {'page_id': page_id}, "tool_output": result}


# Global tools list
tools = [list_books, create_book, create_chapter, create_page, generate_page_image]

# Node
def leo(state: LlamaPressState):
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

    graph = build_workflow()

# Initialize state with token + prompt
initial_state = LlamaPressState(
    messages=[HumanMessage(content="Read the book!")],
    api_token=os.getenv("LLAMAPRESS_API_TOKEN"),   # defined in your .env
    agent_prompt="You are Leo, access the LlamaPress books API."
)

async def main():
    result = await graph.ainvoke(initial_state)
    print(result)

if __name__ == "__main__":
    asyncio.run(main())