class PublicController < ApplicationController
  skip_before_action :authenticate_user!, raise: false

  # Root page of our application.
  # GET /
  def home
    if user_signed_in?
      redirect_to library_books_path
    end
  end

  # Chat page of our application.
  # GET /chat
  def chat
  end
end
