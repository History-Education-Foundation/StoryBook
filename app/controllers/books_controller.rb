class BooksController < ApplicationController
  before_action :authenticate_user!

  def index
    @books = current_user.books
  end

  def new
    @book = current_user.books.new
  end

  def create
    @book = current_user.books.new(book_params)
    if @book.save
      redirect_to books_path, notice: 'Book was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @book = current_user.books.find(params[:id])
  end

  def update
    @book = current_user.books.find(params[:id])
    if @book.update(book_params)
      redirect_to books_path, notice: 'Book was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book = current_user.books.find(params[:id])
    @book.destroy
    redirect_to books_path, notice: 'Book was successfully deleted.'
  end

  def public_show
    @book = Book.find(params[:id])
    if @book.status != "Published"
      redirect_to root_path, alert: "This book is not published."
    end
    # Show minimal, public-friendly book details here.
  end

  def library
    if current_user.student?
      @books = current_user.saved_books_library
    elsif current_user.staff?
      # Union of books they've created and books they've saved (removable)
      created_books = current_user.books
      saved_books = current_user.saved_books_library
      @books = (created_books + saved_books).uniq
    else
      redirect_to books_path, alert: 'My Library is only for students or staff.' and return
    end
  end

  def reader
    @book = Book.find(params[:id])
    if !(current_user.student? && current_user.saved_books_library.exists?(id: @book.id))
      redirect_to books_path, alert: 'You must save this book to your library before reading.' and return
    end
    @chapters = @book.chapters.includes(:pages).order(:id)
  end

  private

  def book_params
    params.require(:book).permit(:title, :learning_outcome, :reading_level, :status)
  end
end
