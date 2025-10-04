class PagesController < ApplicationController
  include LlamaBotRails::ControllerExtensions
  include LlamaBotRails::AgentAuth
  before_action :set_book
  before_action :set_chapter

  llama_bot_allow :create, :update, :generate_image

  def index
    @pages = @chapter.pages
  end

  def new
    @page = @chapter.pages.new
  end

  def create
    @page = @chapter.pages.new(page_params)
    if @page.save
      # Automatically generate AI image using content, if image was not uploaded
      unless @page.image.attached?
        book_title = @book.title.to_s.strip
        book_level = @book.reading_level.to_s.strip
        learning_objective = @book.learning_outcome.to_s.strip
        chapter_title = @chapter.title.to_s.strip
        pages_in_order = @book.chapters.order(:id).map { |c| c.pages.order(:id).to_a }.flatten
        previous_pages = []
        pages_in_order.each do |p|
          break if p.id == @page.id
          previous_pages << p.content.to_s
        end
        @page.generate_picture(
          replace_existing: true,
          book_title: book_title,
          book_level: book_level,
          learning_objective: learning_objective,
          previous_pages: previous_pages.join("\n")
        )
      end
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

  # POST /pages/:id/generate_image
  def generate_image
    @page = @chapter.pages.find(params[:id])
    @book = @chapter.book
    book_title = @book.title.to_s.strip
    book_level = @book.reading_level.to_s.strip
    chapter_title = @chapter.title.to_s.strip
    learning_objective = @book.learning_outcome.to_s.strip
    pages_in_order = @book.chapters.order(:id).map { |c| c.pages.order(:id).to_a }.flatten
    previous_pages = []
    pages_in_order.each do |p|
      break if p.id == @page.id
      previous_pages << p.content.to_s
    end
    @page.image.purge if @page.image.attached?
    chapter_title = @chapter.title.to_s.strip
    @page.generate_picture(
      replace_existing: true,
      book_title: book_title,
      book_level: book_level,
      learning_objective: learning_objective,
      previous_pages: previous_pages.join("\n"),
    )
    redirect_to edit_book_chapter_page_path(@book, @chapter, @page), notice: 'Image generated and attached!'
  rescue => e
    flash[:alert] = "AI image generation failed: #{e.message}"
    redirect_to edit_book_chapter_page_path(@book, @chapter, @page)
  end

  private

  def set_book
    @book = current_user.books.find(params[:book_id])
  end

  def set_chapter
    @chapter = @book.chapters.find(params[:chapter_id])
  end

  def page_params
    params.require(:page).permit(:content, :image, :audio_file)
  end
end
