from langchain_openai import ChatOpenAI
from langchain_core.tools import tool
from dotenv import load_dotenv
load_dotenv()

from langgraph.graph import MessagesState
from langchain_core.messages import HumanMessage, SystemMessage, AIMessage
from typing import Annotated, Optional

from langgraph.graph import START, StateGraph
from langgraph.prebuilt import tools_condition, ToolNode, InjectedState
from langgraph.prebuilt.chat_agent_executor import AgentState

import asyncio
import logging

from app.agents.utils.make_api_request_to_llamapress import make_api_request_to_llamapress

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# System message for student Q&A agent
sys_msg = """You are a helpful reading assistant for students. You help students understand and engage with the book content they're currently reading.

⚠️ CRITICAL: Each conversation is isolated to a SPECIFIC book. The book context is provided in your system message. You MUST:
1. ALWAYS use the get_book_details tool with the provided book_id before answering questions about the book
2. NEVER reference information from previous conversations about different books
3. IGNORE any conversation history that references a different book_id than the current one
4. If unsure about the current book, ALWAYS fetch fresh data using the tools

Your role is to:
- Answer questions about the CURRENT book's content, themes, and characters
- Help students understand difficult concepts or vocabulary FROM THIS BOOK
- Provide context and explanations about what they're reading IN THIS BOOK
- Encourage critical thinking about the material
- Be supportive and encouraging

You have access to the full book content including all chapters and pages. Use the tools available to fetch the book details, chapters, and pages to answer student questions accurately.

Always be encouraging and make learning fun! Use clear, age-appropriate language based on the book's reading level.
"""

# Define custom state
class StudentAgentState(AgentState):
    api_token: str
    agent_prompt: str
    book_id: Optional[str]
    chapter_id: Optional[str]


@tool
async def get_book_details(
    book_id: int,
    state: Annotated[dict, InjectedState],
) -> str:
    """
    Get details about a specific book including its title, learning outcome, and reading level.
    Use this to understand the context of what the student is reading.
    """
    logger.info(f"Getting book details for book {book_id}")
    
    api_token = state.get("api_token")
    if not api_token:
        return "Error: api_token is required but not provided in state."

    # Use the show endpoint to get a specific book
    result = await make_api_request_to_llamapress(
        method="GET",
        endpoint=f"/books/{book_id}.json",
        api_token=api_token,
    )

    if isinstance(result, str):
        return result
    
    return {'tool_name': 'get_book_details', 'tool_args': {'book_id': book_id}, "tool_output": result}


@tool
async def list_chapters(
    book_id: int,
    state: Annotated[dict, InjectedState],
) -> str:
    """
    Lists all chapters in the book. Use this to see the structure of the book and what topics are covered.
    """
    logger.info(f"Listing chapters for book {book_id}")
    
    api_token = state.get("api_token")
    if not api_token:
        return "Error: api_token is required but not provided in state."

    result = await make_api_request_to_llamapress(
        method="GET",
        endpoint=f"/books/{book_id}/chapters.json",
        api_token=api_token,
    )

    if isinstance(result, str):
        return result
    
    return {'tool_name': 'list_chapters', 'tool_args': {'book_id': book_id}, "tool_output": result}


@tool
async def get_chapter_details(
    book_id: int,
    chapter_id: int,
    state: Annotated[dict, InjectedState],
) -> str:
    """
    Get details about a specific chapter including its title and description.
    """
    logger.info(f"Getting chapter {chapter_id} details from book {book_id}")
    
    api_token = state.get("api_token")
    if not api_token:
        return "Error: api_token is required but not provided in state."

    # Use the show endpoint to get a specific chapter
    result = await make_api_request_to_llamapress(
        method="GET",
        endpoint=f"/books/{book_id}/chapters/{chapter_id}.json",
        api_token=api_token,
    )

    if isinstance(result, str):
        return result
    
    return {'tool_name': 'get_chapter_details', 'tool_args': {'book_id': book_id, 'chapter_id': chapter_id}, "tool_output": result}


@tool
async def list_pages(
    book_id: int,
    chapter_id: int,
    state: Annotated[dict, InjectedState],
) -> str:
    """
    Lists all pages within a chapter. Each page contains the actual content of the book.
    Use this to see and reference the specific text the student is reading.
    """
    logger.info(f"Listing pages for chapter {chapter_id} in book {book_id}")
    
    api_token = state.get("api_token")
    if not api_token:
        return "Error: api_token is required but not provided in state."

    result = await make_api_request_to_llamapress(
        method="GET",
        endpoint=f"/books/{book_id}/chapters/{chapter_id}/pages.json",
        api_token=api_token,
    )

    if isinstance(result, str):
        return result
    
    return {'tool_name': 'list_pages', 'tool_args': {'book_id': book_id, 'chapter_id': chapter_id}, "tool_output": result}


@tool
async def get_page_content(
    book_id: int,
    chapter_id: int,
    page_id: int,
    state: Annotated[dict, InjectedState],
) -> str:
    """
    Get the content of a specific page. Use this to reference exact text when answering questions.
    """
    logger.info(f"Getting page {page_id} content from chapter {chapter_id} in book {book_id}")
    
    api_token = state.get("api_token")
    if not api_token:
        return "Error: api_token is required but not provided in state."

    # Use the show endpoint to get a specific page
    result = await make_api_request_to_llamapress(
        method="GET",
        endpoint=f"/books/{book_id}/chapters/{chapter_id}/pages/{page_id}.json",
        api_token=api_token,
    )

    if isinstance(result, str):
        return result
    
    return {'tool_name': 'get_page_content', 'tool_args': {'book_id': book_id, 'chapter_id': chapter_id, 'page_id': page_id}, "tool_output": result}


# Register all tools
tools = [
    get_book_details,
    list_chapters,
    get_chapter_details,
    list_pages,
    get_page_content,
]

# Node
def student_agent(state: StudentAgentState):
    llm = ChatOpenAI(model="gpt-4o")
    llm_with_tools = llm.bind_tools(tools)

    # Get the book context from state
    book_id = state.get("book_id")
    chapter_id = state.get("chapter_id")
    
    context_info = ""
    if book_id:
        context_info += f"\n\n🔴 CRITICAL CONTEXT: The student is CURRENTLY reading Book ID: {book_id}"
        context_info += f"\n\n⚠️ MANDATORY RULES - READ CAREFULLY:"
        context_info += f"\n1. FIRST ACTION: Call get_book_details({book_id}) IMMEDIATELY before answering ANY question"
        context_info += f"\n2. NEVER trust conversation history about book content - it may be from a DIFFERENT book"
        context_info += f"\n3. ALWAYS use the FRESH data returned from get_book_details({book_id})"
        context_info += f"\n4. If you see book content in conversation history that doesn't match the get_book_details result, IGNORE the history"
        context_info += f"\n5. The ONLY valid book for this message is Book ID: {book_id}"
        context_info += f"\n\n🚨 CRITICAL: Even if you recently called get_book_details for a different book_id, you MUST call it again for {book_id}"
        context_info += f"\n🚨 The book_id changes between messages - ALWAYS verify with a fresh get_book_details({book_id}) call"
    else:
        logger.warning(f"⚠️ WARNING: book_id is None or not provided in state!")
        context_info += f"\n\n⚠️ ERROR: No book_id provided. Cannot answer questions about the book."
    if chapter_id:
        context_info += f"\n📖 Current Chapter ID: {chapter_id}"
    
    custom_prompt_instructions = state.get("agent_prompt", "")
    full_sys_msg = SystemMessage(content=f"""{sys_msg}{context_info}

Here are additional instructions provided by the developer: 
<DEVELOPER_INSTRUCTIONS> 
{custom_prompt_instructions} 
</DEVELOPER_INSTRUCTIONS>""")

    return {"messages": [llm_with_tools.invoke([full_sys_msg] + state["messages"])]}


def build_workflow(checkpointer=None):
    # Graph
    builder = StateGraph(StudentAgentState)

    # Define nodes
    builder.add_node("student_agent", student_agent)
    builder.add_node("tools", ToolNode(tools))

    # Define edges
    builder.add_edge(START, "student_agent")
    builder.add_conditional_edges(
        "student_agent",
        tools_condition,
    )
    builder.add_edge("tools", "student_agent")
    
    react_graph = builder.compile(checkpointer=checkpointer)

    return react_graph
