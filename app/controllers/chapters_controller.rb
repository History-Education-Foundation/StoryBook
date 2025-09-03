class ChaptersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book

  def index
    @chapters = @book.chapters
  end

  def new
    @chapter = @book.chapters.new
  end

  def create
    @chapter = @book.chapters.new(chapter_params)
    if @chapter.save
      redirect_to book_chapters_path(@book), notice: 'Chapter was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @chapter = @book.chapters.find(params[:id])
  end

  def update
    @chapter = @book.chapters.find(params[:id])
    if @chapter.update(chapter_params)
      redirect_to book_chapters_path(@book), notice: 'Chapter was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @chapter = @book.chapters.find(params[:id])
    @chapter.destroy
    redirect_to book_chapters_path(@book), notice: 'Chapter was successfully deleted.'
  end

  private

  def set_book
    @book = current_user.books.find(params[:book_id])
  end

  def chapter_params
    params.require(:chapter).permit(:title, :description)
  end
end
