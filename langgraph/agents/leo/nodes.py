from langchain_openai import ChatOpenAI
from langchain_core.tools import tool
from dotenv import load_dotenv
load_dotenv()

from langgraph.graph import MessagesState
from langchain_core.messages import HumanMessage, SystemMessage, AIMessage
from typing import Annotated
import operator

from langchain_core.tools import tool, InjectedToolCallId
from langgraph.types import Command
from langchain_core.messages import ToolMessage
from langgraph.prebuilt import InjectedState
from tavily import TavilyClient
import os

from langgraph.graph import START, StateGraph
from langgraph.prebuilt import tools_condition, ToolNode, InjectedState
from langgraph.prebuilt.chat_agent_executor import AgentState

from typing import NotRequired, Annotated
from typing import Literal
from typing_extensions import TypedDict

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
sys_msg = """You are a helpful assistant that helps teachers create comprehensive lesson plans and articles systematically.

These lesson plans/articles are saved and represented in the database as "books".

An article = a book in our schema. 
A section of the article = a chapter in our schema.
The actual paragraphs/content = a page in our schema. 

This is for organization purposes within the database, but articles are the same as books.

## CRITICAL REQUIREMENT: AGGRESSIVE TODO PLANNING FOR COMPLETE CONTENT

**YOU MUST:**
1. **IMMEDIATELY create a comprehensive TODO list** that maps out ALL chapters and ALL pages within each chapter BEFORE starting any creation
2. **Plan the ENTIRE structure upfront** - don't create things incrementally. Know exactly what the full article will contain.
3. **Execute sequentially** - create 1 chapter, then all its pages, then move to the next chapter
4. **Update your TODO items** to "in_progress" BEFORE creating, then "completed" IMMEDIATELY after finishing each item
5. **Show the user your plan** - display the complete TODO structure so they see the full scope of work planned

Example of proper TODO structure:
```
1. Create book "The Solar System" (pending)
   - Chapter 1: Introduction to the Sun (pending)
     - Page 1: What is the Sun? (pending)
     - Page 2: The Sun's Composition (pending)
     - Page 3: Solar Energy (pending)
   - Chapter 2: Planets in Our Solar System (pending)
     - Page 1: Mercury and Venus (pending)
     - Page 2: Earth and Mars (pending)
     - Page 3: Jupiter and Saturn (pending)
   - Chapter 3: Beyond the Planets (pending)
     - Page 1: The Asteroid Belt (pending)
     - Page 2: Comets and Meteors (pending)
```

**NEVER create content piecemeal.** If a user asks for an article with 3 chapters and 5 pages each, you must plan all 15 pages AND their content sequentially.

**The execution flow must be:**
1. Create the book
2. For each chapter:
   - Create the chapter
   - For each page in that chapter:
     - Create the page content
     - Optionally generate an image
   - Mark chapter complete
3. All done

Your available capabilities include:
- **Create a new article for a lesson **: use `create_book`
- **Create sections for the articles (Chapters)**: use `create_chapter`
- **Update or Delete Chapters**: use `update_chapter` or `delete_chapter`
- **Create actual text content for the article/sections**: use `create_page`
- **Update or Delete Pages**: use `update_page` or `delete_page`
- **Generate Images**: use `generate_page_image`
- **List Chapters**: use `list_chapters`
- **List Pages**: use `list_pages`

When creating or updating a lesson plan, book, the **reading level** must be selected from the following options:
`"7th grade"`, `"8th grade"`, `"9th grade"`, `"10th grade"`, `"11th grade"`, `"12th grade"`.

If a user provides a grade that doesn't match these exactly, choose the closest valid grade level instead.

**Teachers send minimal messages (1-2) before execution.** Get one clarifying question if needed, then BUILD THE COMPLETE TODO PLAN and execute it systematically. No more asking questions—just plan and execute!
"""
# Warning: Brittle - None type will break this when it's injected into the state for the tool call, and it silently fails. So if it doesn't map state types properly from the frontend, it will break. (must be exactly what's defined here).

class Todo(TypedDict):
    """A structured task item for tracking progress through complex workflows.

    Attributes:
        content: Short, specific description of the task
        status: Current state - pending, in_progress, or completed
    """

    content: str
    status: Literal["pending", "in_progress", "completed"]

class LlamaPressState(AgentState):
    api_token: str
    agent_prompt: str
    todos: Annotated[NotRequired[list[Todo]], operator.add] # why did claude code change to annotated.?

WRITE_TODOS_DESCRIPTION = """Use this tool to create and manage a structured task list for your current work session. This helps you track progress, organize complex tasks, and demonstrate thoroughness to the user.
It also helps the user understand the progress of the task and overall progress of their requests.

## When to Use This Tool
Use this tool proactively in these scenarios:

1. Complex multi-step tasks - When a task requires 3 or more distinct steps or actions
2. Non-trivial and complex tasks - Tasks that require careful planning or multiple operations
3. User explicitly requests todo list - When the user directly asks you to use the todo list
4. User provides multiple tasks - When users provide a list of things to be done (numbered or comma-separated)
5. After receiving new instructions - Immediately capture user requirements as todos
6. When you start working on a task - Mark it as in_progress BEFORE beginning work. Ideally you should only have one todo as in_progress at a time
7. After completing a task - Mark it as completed and add any new follow-up tasks discovered during implementation

## When NOT to Use This Tool

Skip using this tool when:
1. There is only a single, straightforward task
2. The task is trivial and tracking it provides no organizational benefit
3. The task can be completed in less than 3 trivial steps
4. The task is purely conversational or informational

NOTE that you should not use this tool if there is only one trivial task to do. In this case you are better off just doing the task directly.

## Examples of When to Use the Todo List

<example>
User: Create a lesson on photosynthesis for 9th graders with 2 chapters and 3 pages each.
Assistant: Perfect! Let me create a comprehensive todo plan for your photosynthesis lesson. I'll map out the entire structure before building it.
*Creates todo list with the following items:*
1. Create book "Photosynthesis: How Plants Make Food" (pending)
2. Chapter 1: What is Photosynthesis? (pending)
   - Page 1: Introduction to Photosynthesis (pending)
   - Page 2: The Role of Sunlight (pending)
   - Page 3: Chloroplasts and Chlorophyll (pending)
3. Chapter 2: The Photosynthesis Process (pending)
   - Page 1: The Light-Dependent Reactions (pending)
   - Page 2: The Calvin Cycle (pending)
   - Page 3: Glucose Production (pending)
*Begins executing the plan sequentially*

<reasoning>
The assistant used the todo list because:
1. Creating a complete lesson requires multiple sequential steps (book → chapters → pages)
2. Planning all 6 pages upfront ensures consistent, high-quality content
3. The hierarchical structure shows the full scope before any creation begins
4. Progress tracking ensures each chapter and page is completed systematically
5. The nested structure maps the database hierarchy (book contains chapters contain pages)
</reasoning>
</example>

<example>
User: Make me a 10th grade article on World War II with 4 chapters about causes, major battles, key figures, and outcomes - 4 pages per chapter.
Assistant: Excellent! Let me build your comprehensive WW2 article with a complete plan for all 16 pages.
*Creates todo list with the following items:*
1. Create book "World War II: A Comprehensive History" (pending)
2. Chapter 1: The Causes of World War II (pending)
   - Page 1: Treaty of Versailles and Economic Crisis (pending)
   - Page 2: Rise of Fascism in Europe (pending)
   - Page 3: Militarism and Expansionism (pending)
   - Page 4: The Path to War (pending)
3. Chapter 2: Major Battles and Campaigns (pending)
   - Page 1: Early Axis Victories (pending)
   - Page 2: The Battle of Britain (pending)
   - Page 3: Operation Barbarossa (pending)
   - Page 4: The Pacific Theater (pending)
4. Chapter 3: Key Historical Figures (pending)
   - Page 1: Political Leaders (pending)
   - Page 2: Military Commanders (pending)
   - Page 3: Resistance and Opposition (pending)
   - Page 4: Impact on History (pending)
5. Chapter 4: Outcomes and Legacy (pending)
   - Page 1: End of the War (pending)
   - Page 2: Formation of the United Nations (pending)
   - Page 3: Reconstruction and Cold War (pending)
   - Page 4: Lessons and Remembrance (pending)
*Executes systematically: Book → Chapter 1 + all 4 pages → Chapter 2 + all 4 pages → etc.*

<reasoning>
The assistant used the todo list because:
1. Creating 16 pages across 4 chapters is a complex multi-step operation
2. Planning the complete structure prevents piecemeal creation and ensures quality
3. The nested format mirrors the actual book/chapter/page hierarchy in the database
4. Teachers can see the complete scope and adjust before execution begins
5. Sequential execution ensures consistent pacing and thorough content coverage
6. Progress tracking on each item maintains accountability and prevents skipped content
</reasoning>
</example>

<example>
User: I need a biology lesson on the human body for 7th graders with 3 main chapters covering systems, organs, and cells. Each chapter needs 2-3 pages.
Assistant: Great! Let me plan out your human body lesson with all the chapters and pages mapped before we start building.
*Creates todo list with the following items:*
1. Create book "The Human Body: Systems, Organs, and Cells" (pending)
2. Chapter 1: Body Systems Overview (pending)
   - Page 1: The Circulatory System (pending)
   - Page 2: The Respiratory System (pending)
   - Page 3: The Nervous System (pending)
3. Chapter 2: Organs and Their Functions (pending)
   - Page 1: The Heart, Lungs, and Brain (pending)
   - Page 2: The Digestive and Excretory Systems (pending)
4. Chapter 3: Cells: The Building Blocks of Life (pending)
   - Page 1: What are Cells? (pending)
   - Page 2: Cell Structure and Organelles (pending)
   - Page 3: How Cells Work Together (pending)
*Now executing: Create book → Chapter 1 (create + 3 pages) → Chapter 2 (create + 2 pages) → Chapter 3 (create + 3 pages)*

<reasoning>
The assistant used the todo list because:
1. Multiple chapters with varying page counts requires upfront planning
2. Mapping all content before creation ensures consistency and prevents omissions
3. Teachers see the complete lesson structure in one view
4. Sequential execution of chapters ensures systematic progress
5. Real-time status updates (pending → in_progress → completed) demonstrate active progress
</reasoning>
</example>

## Examples of When NOT to Use the Todo List

<example>
User: How do I print 'Hello World' in Python?
Assistant: In Python, you can print "Hello World" with this simple code:

python
print("Hello World")

This will output the text "Hello World" to the console when executed.</assistant>

<reasoning>
The assistant did not use the todo list because this is a single, trivial task that can be completed in one step. There's no need to track multiple tasks or steps for such a straightforward request.
</reasoning>
</example>

<example>
User: What's the best way to water houseplants?
Assistant: The best way to water houseplants depends on the specific plant type, but here are some general guidelines:

- Check soil moisture by inserting your finger about 1-2 inches into the soil
- Water thoroughly when the top inch feels dry, allowing water to drain from the bottom
- Use room temperature water and water in the morning when possible
- Avoid overwatering, which is more harmful than underwatering for most plants

Different plants have different needs, so it's important to research your specific varieties for optimal care.

<reasoning>
The assistant did not use the todo list because this is an informational request with no actual tasks to complete. The user is simply asking for advice and explanation, not for the assistant to perform multiple steps or activities.
</reasoning>
</example>

<example>
User: Can you add a comment to the calculateTotal function to explain what it does?
Assistant: Sure, let me add a comment to the calculateTotal function to explain what it does.
* Uses the Edit tool to add a comment to the calculateTotal function *

<reasoning>
The assistant did not use the todo list because this is a single, straightforward task confined to one location. Adding a comment doesn't require tracking multiple steps or systematic organization.
</reasoning>
</example>

<example>
User: What time is it in Tokyo right now?
Assistant: I'll check the current time in Tokyo for you.

*Searches for current time in Tokyo*

The current time in Tokyo, Japan is [current time]. Tokyo is in the Japan Standard Time (JST) zone, which is UTC+9.

<reasoning>
The assistant did not use the todo list because this is a single information lookup with immediate results. There are no multiple steps to track or organize, making the todo list unnecessary for this straightforward request.
</reasoning>
</example>

## Task States and Management

1. **Task States**: Use these states to track progress:
   - pending: Task not yet started
   - in_progress: Currently working on (limit to ONE task at a time)
   - completed: Task finished successfully

2. **Task Management**:
   - Update task status in real-time as you work
   - Mark tasks complete IMMEDIATELY after finishing (don't batch completions)
   - Only have ONE task in_progress at any time
   - Complete current tasks before starting new ones
   - Remove tasks that are no longer relevant from the list entirely

3. **Task Completion Requirements**:
   - ONLY mark a task as completed when you have FULLY accomplished it
   - If you encounter errors, blockers, or cannot finish, keep the task as in_progress
   - When blocked, create a new task describing what needs to be resolved
   - Never mark a task as completed if:
     - There are unresolved issues or errors
     - Work is partial or incomplete
     - You encountered blockers that prevent completion
     - You couldn't find necessary resources or dependencies
     - Quality standards haven't been met

4. **Task Breakdown**:
   - Create specific, actionable items
   - Break complex tasks into smaller, manageable steps
   - Use clear, descriptive task names

When in doubt, use this tool. Being proactive with task management demonstrates attentiveness and ensures you complete all requirements successfully."""

@tool(description=WRITE_TODOS_DESCRIPTION)
def write_todos(
    todos: list[Todo], tool_call_id: Annotated[str, InjectedToolCallId]
) -> Command:
    return Command(
        update={
            "todos": todos,
            "messages": [
                ToolMessage(f"Updated todo list to {todos}", tool_call_id=tool_call_id)
            ],
        }
    )

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
tools = [write_todos, list_books, create_book, create_chapter, create_page, generate_page_image, delete_book, delete_chapter, delete_page, update_book, update_chapter, update_page, list_chapters, list_pages]

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