from langchain_openai import ChatOpenAI
from langchain_core.tools import tool
from langgraph.graph import StateGraph, START, END
from langgraph.prebuilt import tools_condition, ToolNode, InjectedState
from langgraph.prebuilt.chat_agent_executor import AgentState
from langchain_core.messages import SystemMessage, HumanMessage, AIMessage
from typing import Annotated, Optional, TypedDict, Literal
import logging

logger = logging.getLogger(__name__)

# ============================================================================
# TODO STRUCTURE
# ============================================================================

class Todo(TypedDict):
    """A structured task item for tracking progress through complex workflows.

    Attributes:
        content: Short, specific description of the task
        status: Current state – pending, in_progress, or completed
    """
    content: str
    status: Literal["pending", "in_progress", "completed"]


# ============================================================================
# STATE DEFINITION
# ============================================================================

class TodoManagerState(AgentState):
    """State for the Todo Manager agent."""
    api_token: str
    agent_name: str
    current_task_id: Optional[int] = None  # Track which todo we're working on
    todos: list[Todo] = []  # Session-scoped todos


# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

def format_status_icon(status: str) -> str:
    """Convert status to visual icon."""
    if status == "pending":
        return "☐"
    elif status == "in_progress":
        return "[*]"
    elif status == "completed":
        return "✅"
    return "?"


def format_todo_line(todo: Todo) -> str:
    """Format a single todo line with status icon and optional strikethrough."""
    icon = format_status_icon(todo["status"])
    content = todo["content"]
    
    if todo["status"] == "completed":
        content = f"~~{content}~~"
    
    return f"{icon} {content}"


def format_todos_list(todos: list[Todo]) -> str:
    """Format entire todos list for display."""
    if not todos:
        return "📋 **No todos yet!**"
    
    lines = ["📋 **Update Todos**"]
    for todo in todos:
        lines.append(f" {format_todo_line(todo)}")
    
    return "\n".join(lines)


# ============================================================================
# TOOL DEFINITIONS
# ============================================================================

@tool
async def create_task(
    task_description: str,
    state: Annotated[dict, InjectedState],
) -> str:
    """Create a new task from the user's request and mark it as in_progress.
    
    This is called when the agent receives a new user request. It:
    1. Creates a todo for the task
    2. Marks it as in_progress (agent is now working on it)
    3. Returns the todo list with the new task
    
    Args:
        task_description (str): The task the user wants done
        
    Returns:
        Formatted todo list with the new task
    """
    logger.info(f"Creating task: {task_description}")
    
    todos = state.get("todos", [])
    task_id = len(todos)
    
    new_todo: Todo = {
        "content": task_description,
        "status": "in_progress"  # Immediately mark as in_progress - we're working on it!
    }
    
    todos.append(new_todo)
    state["todos"] = todos
    state["current_task_id"] = task_id
    
    formatted_list = format_todos_list(todos)
    
    return f"{formatted_list}\n\n🚀 **Starting work on this task...**"


@tool
async def update_current_task_status(
    new_status: Literal["pending", "in_progress", "completed"],
    state: Annotated[dict, InjectedState],
    progress_message: Optional[str] = None,
) -> str:
    """Update the status of the current task being worked on.
    
    Use this tool to track progress:
    - "in_progress": Actively working on sub-steps
    - "completed": Task finished successfully
    - "pending": Backing off, will try again later
    
    Args:
        new_status (str): New status for current task
        progress_message (str): Optional message about what's happening
        
    Returns:
        Updated todo list
    """
    logger.info(f"Updating current task status to: {new_status}")
    
    todos = state.get("todos", [])
    task_id = state.get("current_task_id")
    
    if task_id is None or task_id >= len(todos):
        return "❌ No active task to update"
    
    todos[task_id]["status"] = new_status
    state["todos"] = todos
    
    formatted_list = format_todos_list(todos)
    
    if progress_message:
        return f"{formatted_list}\n\n💬 {progress_message}"
    
    return formatted_list


@tool
async def add_subtask(
    subtask_description: str,
    state: Annotated[dict, InjectedState],
) -> str:
    """Add a subtask to the current main task.
    
    This helps track detailed steps as you work through a larger task.
    
    Args:
        subtask_description (str): Description of the subtask
        
    Returns:
        Updated todo list with subtask added
    """
    logger.info(f"Adding subtask: {subtask_description}")
    
    todos = state.get("todos", [])
    
    # Create a subtask with slight indentation in content
    subtask: Todo = {
        "content": f"  └─ {subtask_description}",
        "status": "pending"
    }
    
    todos.append(subtask)
    state["todos"] = todos
    
    formatted_list = format_todos_list(todos)
    
    return f"{formatted_list}\n\n📝 **Subtask added**"


@tool
async def complete_current_task(
    completion_message: str,
    state: Annotated[dict, InjectedState],
) -> str:
    """Mark the current task as completed with a summary message.
    
    Call this when the task is finished successfully.
    
    Args:
        completion_message (str): Summary of what was accomplished
        
    Returns:
        Updated todo list with task marked complete
    """
    logger.info(f"Completing current task: {completion_message}")
    
    todos = state.get("todos", [])
    task_id = state.get("current_task_id")
    
    if task_id is None or task_id >= len(todos):
        return "❌ No active task to complete"
    
    todos[task_id]["status"] = "completed"
    state["todos"] = todos
    state["current_task_id"] = None
    
    formatted_list = format_todos_list(todos)
    
    return f"{formatted_list}\n\n✅ **Task completed!**\n\n📌 {completion_message}"


@tool
async def mark_subtask_complete(
    subtask_index: int,
    state: Annotated[dict, InjectedState],
) -> str:
    """Mark a specific subtask as complete.
    
    Args:
        subtask_index (int): Position in the todo list (1-indexed)
        
    Returns:
        Updated todo list
    """
    logger.info(f"Marking subtask {subtask_index} as complete")
    
    todos = state.get("todos", [])
    
    if subtask_index < 1 or subtask_index > len(todos):
        return f"❌ Subtask index {subtask_index} not found"
    
    todos[subtask_index - 1]["status"] = "completed"
    state["todos"] = todos
    
    formatted_list = format_todos_list(todos)
    
    return formatted_list


@tool
async def list_todos(state: Annotated[dict, InjectedState]) -> str:
    """Display all todos with their current status.
    
    Returns:
        Formatted todo list
    """
    logger.info("Listing all todos")
    todos = state.get("todos", [])
    
    formatted_list = format_todos_list(todos)
    
    return formatted_list


@tool
async def clear_todos(state: Annotated[dict, InjectedState]) -> str:
    """Clear all todos and reset.
    
    Returns:
        Confirmation message
    """
    logger.info("Clearing all todos")
    
    state["todos"] = []
    state["current_task_id"] = None
    
    return "🗑️ All todos cleared!"


# ============================================================================
# TOOL LIST
# ============================================================================

tools = [
    create_task,
    update_current_task_status,
    add_subtask,
    complete_current_task,
    mark_subtask_complete,
    list_todos,
    clear_todos,
]


# ============================================================================
# SYSTEM MESSAGE
# ============================================================================

sys_msg = """You are an aggressive Task Execution Manager. When a user asks you to do something:

**YOUR WORKFLOW:**
1. **Immediately call `create_task`** with the user's request as task_description
   - This creates a todo and marks it as [*] in_progress
   - The todo list displays instantly
   
2. **Execute the task** by making tool calls, API requests, code changes, etc.
   
3. **Call `update_current_task_status` frequently** to show progress:
   - Keep it at "in_progress" as you work through steps
   - Include `progress_message` to explain what you're doing
   - Example: `update_current_task_status("in_progress", "Fetching data from API...")`
   
4. **Call `add_subtask`** for major steps to break down complex work
   - This helps track multi-step processes visually
   - Example: "Implementing user authentication" or "Testing the function"
   
5. **Mark subtasks complete** with `mark_subtask_complete` as you finish each step
   
6. **Call `complete_current_task`** when finished
   - Include a summary of what was accomplished
   - Example: `complete_current_task("Successfully created user table with 5 fields")`

**AGGRESSIVE UPDATE RULES:**
- Update the todo FREQUENTLY (every major step, not just start/end)
- Use progress_message to narrate what you're doing in real-time
- Show the user you're working through their request step-by-step
- The todo list IS your progress indicator - keep it visible
- If something goes wrong, still mark it complete with an error summary

**EXAMPLE INTERACTION:**

User: "Create a User model for my Rails app with name, email, and phone fields"

1. You call: `create_task("Create a User model for Rails app with name, email, phone")`
   → Todo displays: [*] Create a User model...

2. You call: `add_subtask("Generate Rails model scaffold")`
3. You call: `update_current_task_status("in_progress", "Running rails generate model User...")`
   → Todo shows [*] main task, ☐ subtask
   
4. You make the generator call
5. You call: `mark_subtask_complete(2)`
   → Subtask now shows ✅

6. You call: `add_subtask("Add database migration fields")`
7. You call: `update_current_task_status("in_progress", "Writing migration for name, email, phone fields...")`

8. You write the migration
9. You call: `mark_subtask_complete(3)`

10. You call: `complete_current_task("User model created with name, email, phone. Migration ready to run.")`
    → Todo shows ✅ ~~Create a User model...~~ DONE!

**KEY PRINCIPLES:**
- Never ask the user for confirmation before creating the task - just create it!
- Update the todo list as you work - this is your progress indicator
- Be verbose with progress_message - the user wants to SEE you working
- Use subtasks to break down complex multi-step requests
- Always complete the main task when done (even if with errors)"""


# ============================================================================
# WORKFLOW BUILDER
# ============================================================================

def build_workflow(checkpointer=None):
    """Build the Todo Manager agent workflow."""
    builder = StateGraph(TodoManagerState)

    def initialize_task_node(state: TodoManagerState):
        """
        MANDATORY FIRST STEP: Extract the user's request and create a todo.
        This ensures EVERY user message gets tracked as a todo.
        """
        logger.info("=== INITIALIZE TASK NODE ===")
        messages = state.get("messages", [])
        
        # Get the last user message
        user_message = None
        for msg in reversed(messages):
            if isinstance(msg, HumanMessage):
                user_message = msg.content
                break
        
        if not user_message:
            user_message = "Process request"
        
        # Check if we've already created a task for this message
        todos = state.get("todos", [])
        if len(todos) > 0 and state.get("current_task_id") is not None:
            # Already have an active task, proceed to agent
            logger.info("Task already exists, moving to agent")
            return state
        
        # CREATE THE TODO NOW
        logger.info(f"Creating initial todo for: {user_message}")
        
        task_id = len(todos)
        new_todo: Todo = {
            "content": user_message,
            "status": "in_progress"
        }
        todos.append(new_todo)
        
        formatted_list = format_todos_list(todos)
        
        # Add the todo display to messages so user sees it
        todo_message = f"📋 **Update Todos**\n{formatted_list}\n\n🚀 **Starting work on this task...**"
        
        state["todos"] = todos
        state["current_task_id"] = task_id
        state["messages"] = messages + [AIMessage(content=todo_message)]
        
        logger.info(f"Todo created. Current state: {len(todos)} todos, task_id: {task_id}")
        
        return state

    def agent_node(state: TodoManagerState):
        """Agent node that processes user messages and calls tools."""
        logger.info("=== AGENT NODE ===")
        llm = ChatOpenAI(model="gpt-4.1")
        llm_with_tools = llm.bind_tools(tools)
        full_sys_msg = SystemMessage(content=sys_msg)
        
        messages = state.get("messages", [])
        result = llm_with_tools.invoke([full_sys_msg] + messages)
        
        logger.info(f"Agent response type: {type(result).__name__}")
        
        return {"messages": [result]}

    def should_continue(state: TodoManagerState):
        """Determine if we should continue to tools or end."""
        logger.info("=== SHOULD_CONTINUE CHECK ===")
        messages = state.get("messages", [])
        last_message = messages[-1]
        
        # If last message has tool_calls, go to tools
        if hasattr(last_message, "tool_calls") and last_message.tool_calls:
            logger.info(f"Tool calls detected: {len(last_message.tool_calls)} calls")
            return "tools"
        
        # Otherwise end
        logger.info("No tool calls, ending")
        return "end"

    # Build the graph
    builder.add_node("initialize_task", initialize_task_node)
    builder.add_node("agent", agent_node)
    builder.add_node("tools", ToolNode(tools))

    # START -> initialize task (MANDATORY) -> agent -> conditional routing
    builder.add_edge(START, "initialize_task")
    builder.add_edge("initialize_task", "agent")
    builder.add_conditional_edges("agent", should_continue, {"tools": "tools", "end": END})
    builder.add_edge("tools", "agent")  # After tools, loop back to agent

    return builder.compile(checkpointer=checkpointer)
