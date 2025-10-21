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
from app.agents.utils.make_api_request_to_llamapress import make_api_request_to_llamapress

# Define base paths relative to project root
SCRIPT_DIR = Path(__file__).parent.resolve()
PROJECT_ROOT = SCRIPT_DIR.parent.parent.parent  # Go up to LlamaBot root
APP_DIR = PROJECT_ROOT / 'app'

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# System message
sys_msg = """You are a helpful assistant. Your favorite animal is cyborg llama.

Your available capabilities include:
- **Create the Book**: use `create_book`
- **Update a Book**: use `update_book`
- **Delete a Book**: use `delete_book`
- **Create Chapters**: use `create_chapter`
- **Update or Delete Chapters**: use `update_chapter` or `delete_chapter`
- **Create Pages**: use `create_page`
- **Update or Delete Pages**: use `update_page` or `delete_page`
- **Generate Images**: use `generate_page_image`
- **List Chapters**: use `list_chapters`
- **List Pages**: use `list_pages`

When creating or updating a book, the **reading level** must be selected from the following options:
`"7th grade"`, `"8th grade"`, `"9th grade"`, `"10th grade"`, `"11th grade"`, `"12th grade"`.

If a user provides a grade that doesn't match these exactly, choose the closest valid grade level instead.

Always confirm with the user before creating or editing content, and remember to extract the IDs from the results of `create_` tools to use them in subsequent steps.
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
async def list_chapters(
    state: Annotated[dict, InjectedState],
    book_id: int,
) -> str:
    """
    Lists all chapters for the given book ID.
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
    
    return {'toolname': 'list_chapters', 'tool args': {'book_id': book_id}, "tool_output": result}


@tool
async def list_pages(
    state: Annotated[dict, InjectedState],
    book_id: int,
    chapter_id: int,
) -> str:
    """
    Lists all pages within a given chapter.
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
    
    return {'toolname': 'list_pages', 'tool args': {'book_id': book_id, 'chapter_id': chapter_id}, "tool_output": result}


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
        payload=book_data,
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
        payload=chapter_data,
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
        payload=page_data,
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


@tool
async def delete_book(
    state: Annotated[dict, InjectedState],
    book_id: int,
) -> str:
    """
    Deletes a specific book by ID.
    """
    logger.info(f"Deleting book {book_id}")
    api_token = state.get("api_token")
    if not api_token:
        return "Error: api_token is required but not provided in state."

    # First, get the book details to capture the title before deleting
    book_info = await make_api_request_to_llamapress(
        method="GET",
        endpoint=f"/books/{book_id}.json",
        api_token=api_token,
    )

    # Now delete the book
    result = await make_api_request_to_llamapress(
        method="DELETE",
        endpoint=f"/books/{book_id}.json",
        api_token=api_token,
    )
    if isinstance(result, str):
        return result

    # Return the book info (which includes title) as the output
    return {'toolname': 'delete_book', 'tool args': {'book_id': book_id}, 'tool_output': book_info if isinstance(book_info, dict) else result}


@tool
async def delete_chapter(
    state: Annotated[dict, InjectedState],
    book_id: int,
    chapter_id: int,
) -> str:
    """
    Deletes a specific chapter by ID within a book.
    """
    logger.info(f"Deleting chapter {chapter_id} from book {book_id}")
    api_token = state.get("api_token")
    if not api_token:
        return "Error: api_token is required but not provided in state."

    # First, get the chapter details to capture the title before deleting
    chapter_info = await make_api_request_to_llamapress(
        method="GET",
        endpoint=f"/books/{book_id}/chapters/{chapter_id}.json",
        api_token=api_token,
    )

    # Now delete the chapter
    result = await make_api_request_to_llamapress(
        method="DELETE",
        endpoint=f"/books/{book_id}/chapters/{chapter_id}.json",
        api_token=api_token,
    )
    if isinstance(result, str):
        return result

    # Return the chapter info (which includes title) as the output
    return {'toolname': 'delete_chapter', 'tool args': {'chapter_id': chapter_id, 'book_id': book_id}, 'tool_output': chapter_info if isinstance(chapter_info, dict) else result}


@tool
async def delete_page(
    state: Annotated[dict, InjectedState],
    book_id: int,
    chapter_id: int,
    page_number: int,
) -> str:
    """
    Deletes a specific page by its position (page number) within a chapter.
    Page numbers start at 1 (e.g., page_number=1 is the first page, page_number=2 is the second page, etc.).
    """
    logger.info(f"Deleting page number {page_number} from chapter {chapter_id}")
    api_token = state.get("api_token")
    if not api_token:
        return "Error: api_token is required but not provided in state."

    # First, get all pages in the chapter to find the page at the given position
    pages_result = await make_api_request_to_llamapress(
        method="GET",
        endpoint=f"/books/{book_id}/chapters/{chapter_id}/pages.json",
        api_token=api_token,
    )

    if isinstance(pages_result, str):
        return pages_result

    if not isinstance(pages_result, list) or len(pages_result) < page_number:
        return f"Error: Page {page_number} does not exist in this chapter. Chapter has {len(pages_result) if isinstance(pages_result, list) else 0} pages."

    # Get the page at the specified position (page_number - 1 because arrays are 0-indexed)
    page_to_delete = pages_result[page_number - 1]
    page_id = page_to_delete['id']

    logger.info(f"Page number {page_number} corresponds to page ID {page_id}")

    # Now delete the page
    result = await make_api_request_to_llamapress(
        method="DELETE",
        endpoint=f"/books/{book_id}/chapters/{chapter_id}/pages/{page_id}.json",
        api_token=api_token,
    )
    if isinstance(result, str):
        return result

    # Return the page info as the output, including the page number for display
    page_to_delete['page_number'] = page_number
    return {'toolname': 'delete_page', 'tool args': {'page_number': page_number, 'chapter_id': chapter_id, 'book_id': book_id}, 'tool_output': {'page': page_to_delete}}


@tool
async def update_book(
    state: Annotated[dict, InjectedState],
    book_id: int,
    title: str = None,
    learning_outcome: str = None,
    reading_level: str = None,
) -> str:
    """
    Updates a book's attributes (title, learning outcome, reading level).
    Any combination of these fields may be provided.
    """
    logger.info(f"Updating book {book_id}")
    api_token = state.get("api_token")
    if not api_token:
        return "Error: api_token is required but not provided in state."

    payload = {"book": {}}
    if title:
        payload["book"]["title"] = title
    if learning_outcome:
        payload["book"]["learning_outcome"] = learning_outcome
    if reading_level:
        payload["book"]["reading_level"] = reading_level

    result = await make_api_request_to_llamapress(
        method="PUT",
        endpoint=f"/books/{book_id}.json",
        api_token=api_token,
        payload=payload,
    )

    if isinstance(result, str):
        return result

    # Build tool args with only the fields that were actually updated
    updated_args = {'book_id': book_id}
    if title:
        updated_args['title'] = title
    if learning_outcome:
        updated_args['learning_outcome'] = learning_outcome
    if reading_level:
        updated_args['reading_level'] = reading_level

    return {
        'toolname': 'update_book',
        'tool args': updated_args,
        'tool_output': result
    }


@tool
async def update_chapter(
    state: Annotated[dict, InjectedState],
    book_id: int,
    chapter_id: int,
    title: str = None,
    description: str = None,
) -> str:
    """
    Updates a specific chapter by ID within a book.
    Only provided fields (title, description) will be updated.
    """
    logger.info(f"Updating chapter {chapter_id} in book {book_id}")

    api_token = state.get("api_token")
    if not api_token:
        return "Error: api_token is required but not provided in state."

    # Build payload dynamically
    chapter_data = {"chapter": {}}
    if title:
        chapter_data["chapter"]["title"] = title
    if description:
        chapter_data["chapter"]["description"] = description

    if not chapter_data["chapter"]:
        return "Error: No fields provided to update."

    result = await make_api_request_to_llamapress(
        method="PUT",
        endpoint=f"/books/{book_id}/chapters/{chapter_id}.json",
        api_token=api_token,
        payload=chapter_data,
    )

    if isinstance(result, str):
        return result

    # Build tool args with only the fields that were actually updated
    updated_args = {"book_id": book_id, "chapter_id": chapter_id}
    if title:
        updated_args['title'] = title
    if description:
        updated_args['description'] = description

    logger.info(f"📝 update_chapter returning - updated_args: {updated_args}")
    logger.info(f"📝 update_chapter returning - title param: {title}, description param: {description}")

    return {
        "toolname": "update_chapter",
        "tool args": updated_args,
        "tool_output": result,
    }

@tool
async def update_page(
    state: Annotated[dict, InjectedState],
    book_id: int,
    chapter_id: int,
    page_number: int,
    content: str = None,
) -> str:
    """
    Updates a specific page by its position (page number) within a chapter.
    Page numbers start at 1 (e.g., page_number=1 is the first page, page_number=2 is the second page, etc.).
    Only provided fields (content) will be updated.
    """
    logger.info(f"Updating page number {page_number} in chapter {chapter_id} of book {book_id}")

    api_token = state.get("api_token")
    if not api_token:
        return "Error: api_token is required but not provided in state."

    # First, get all pages in the chapter to find the page at the given position
    pages_result = await make_api_request_to_llamapress(
        method="GET",
        endpoint=f"/books/{book_id}/chapters/{chapter_id}/pages.json",
        api_token=api_token,
    )

    if isinstance(pages_result, str):
        return pages_result

    if not isinstance(pages_result, list) or len(pages_result) < page_number:
        return f"Error: Page {page_number} does not exist in this chapter. Chapter has {len(pages_result) if isinstance(pages_result, list) else 0} pages."

    # Get the page at the specified position (page_number - 1 because arrays are 0-indexed)
    page_to_update = pages_result[page_number - 1]
    page_id = page_to_update['id']

    logger.info(f"Page number {page_number} corresponds to page ID {page_id}")

    # Build payload dynamically
    page_data = {"page": {}}
    if content:
        page_data["page"]["content"] = content

    if not page_data["page"]:
        return "Error: No fields provided to update."

    result = await make_api_request_to_llamapress(
        method="PUT",
        endpoint=f"/books/{book_id}/chapters/{chapter_id}/pages/{page_id}.json",
        api_token=api_token,
        payload=page_data,
    )

    if isinstance(result, str):
        return result

    # Build tool args with only the fields that were actually updated
    updated_args = {
        "book_id": book_id,
        "chapter_id": chapter_id,
        "page_number": page_number,
    }
    if content:
        updated_args['content'] = content

    return {
        "toolname": "update_page",
        "tool args": updated_args,
        "tool_output": result,
    }

# breakpoint()
# Global tools list
tools = [list_books, create_book, create_chapter, create_page, generate_page_image, delete_book, delete_chapter, delete_page, update_book, update_chapter, update_page, list_chapters, list_pages]

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