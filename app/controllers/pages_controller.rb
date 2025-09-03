class PagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book
  before_action :set_chapter

  def index
    @pages = @chapter.pages
  end

  def new
    @page = @chapter.pages.new
  end

  def create
    @page = @chapter.pages.new(page_params)
    if @page.save
      redirect_to book_chapter_pages_path(@book, @chapter), notice: 'Page was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @page = @chapter.pages.find(params[:id])
  end

  def update
    @page = @chapter.pages.find(params[:id])
    if @page.update(page_params)
      redirect_to book_chapter_pages_path(@book, @chapter), notice: 'Page was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @page = @chapter.pages.find(params[:id])
    @page.destroy
    redirect_to book_chapter_pages_path(@book, @chapter), notice: 'Page was successfully deleted.'
  end

  private

  def set_book
    @book = current_user.books.find(params[:book_id])
  end

  def set_chapter
    @chapter = @book.chapters.find(params[:chapter_id])
  end

  def page_params
    params.require(:page).permit(:content)
  end
end
