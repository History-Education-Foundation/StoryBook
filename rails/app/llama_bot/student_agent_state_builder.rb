# frozen_string_literal: true

class StudentAgentStateBuilder
  def initialize(params:, context:)
    @params = params
    @context = context
  end

  def build
    raw_params = @params["raw_params"] || {}

    # Extract book and chapter information from the request
    book_id = nil
    chapter_id = nil

    # Try to get book_id from raw_params (from the reader page)
    if raw_params["controller"] == "books" && raw_params["action"] == "reader"
      book_id = raw_params["id"]
    end

    # If book_id is provided explicitly in params, use that
    book_id = @params["book_id"] if @params["book_id"].present?
    chapter_id = @params["chapter_id"] if @params["chapter_id"].present?

    # Build the state hash
    {
      message: @params["message"],
      thread_id: @params["thread_id"],
      api_token: @context[:api_token],
      agent_name: "student",  # Must match langgraph.json key
      book_id: book_id,
      chapter_id: chapter_id,
      agent_prompt: "You are a friendly reading assistant helping students understand the book they're reading."
    }
  end
end
