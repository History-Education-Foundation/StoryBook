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

  # POST /pages/:id/generate_image
  def generate_image
    @page = @chapter.pages.find(params[:id])
    prompt = params[:image_description]
    begin
      # Overwrite the current image with a new AI generated one
      @page.image.purge if @page.image.attached?
      OpenAi.new.generate_image(prompt, attach_to: @page, attachment_name: :image)
      redirect_to edit_book_chapter_page_path(@book, @chapter, @page), notice: 'Image generated and attached!'
    rescue => e
      flash[:alert] = "AI image generation failed: #{e.message}"
      redirect_to edit_book_chapter_page_path(@book, @chapter, @page)
    end
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
