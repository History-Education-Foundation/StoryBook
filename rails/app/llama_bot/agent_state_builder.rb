# frozen_string_literal: true
#
# Customize the params sent to your LangGraph agent here.
# Uncomment the line in the initializer to activate this builder.
class AgentStateBuilder
  def initialize(params:, context:)
    @params = params
    @context = context
  end

  def build
    # TODO:  and make it so that in the websocket connection, change the agent name away from "leo" and change it to "leo-student"
    # that way agent_name: "leo-student" gets passed is

    # Build the enhanced agent prompt with page context
    enhanced_prompt = build_enhanced_prompt(@params["page_context"])

    {
      message: @params["message"], # Rails param from JS/chat UI. This is the user's message to the agent.
      thread_id: @params["thread_id"], # This is the thread id for the agent. It is used to track the conversation history.
      api_token: @context["api_token"], # This is an authenticated API token for the agent, so that it can authenticate with us. (It may need access to resources on our Rails app, such as the Rails Console.)
      agent_prompt: enhanced_prompt, # System prompt with page context injected
      # agent_name: "leo" # This routes to the appropriate LangGraph agent as defined in LlamaBot/langgraph.json, and enables us to access different agents on our LlamaBot server.
      agent_name: "leo",
      page_context: @params["page_context"] # Page context from the frontend (URL, page name, action, resource type, etc.)
    }
  end

  private

  def build_enhanced_prompt(page_context)
    base_prompt = LlamaBotRails.agent_prompt_text

    if page_context.blank?
      return base_prompt
    end

    # Convert page_context to a readable string for the prompt
    page_context_text = format_page_context(page_context)

    # Inject the page context into the system prompt
    "#{base_prompt}\n\n## Current Page Context\n#{page_context_text}"
  end

  def format_page_context(page_context)
    return "" if page_context.blank?

    context_lines = []
    
    context_lines << "- Page Name: #{page_context['pageName']}" if page_context['pageName'].present?
    context_lines << "- Action: #{page_context['action']}" if page_context['action'].present?
    context_lines << "- Resource Type: #{page_context['resourceType']}" if page_context['resourceType'].present?
    context_lines << "- Resource ID: #{page_context['resourceId']}" if page_context['resourceId'].present?
    context_lines << "- Parent Resource Type: #{page_context['parentResourceType']}" if page_context['parentResourceType'].present?
    context_lines << "- Parent Resource ID: #{page_context['parentResourceId']}" if page_context['parentResourceId'].present?
    context_lines << "- Page Title: #{page_context['pageTitle']}" if page_context['pageTitle'].present?

    context_lines.join("\n")
  end
end
