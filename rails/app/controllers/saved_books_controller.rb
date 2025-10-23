class SavedBooksController < ApplicationController
  before_action :authenticate_user!

  def create
    @book = Book.find(params[:id])  # 👈 changed
    if current_user.saved_books.exists?(book: @book)
      redirect_to request.referer.presence || library_books_path(request.query_parameters), alert: 'Book is already in your library.'
    else
      if current_user.saved_books.create(book: @book)
        redirect_to request.referer.presence || library_books_path(request.query_parameters), notice: 'Book added to your library.'
      else
        redirect_to request.referer.presence || library_books_path(request.query_parameters), alert: 'Book could not be added. Please try again.'
      end
    end
  end

  def destroy
    @book = Book.find(params[:id])  # 👈 changed
    saved = current_user.saved_books.find_by(book: @book)
    saved&.destroy
    redirect_to request.referer.presence || library_books_path(request.query_parameters), notice: 'Book removed from your library.'
  end
end