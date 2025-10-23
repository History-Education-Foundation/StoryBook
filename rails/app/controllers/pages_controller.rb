class PagesController < ApplicationController
  include LlamaBotRails::ControllerExtensions
  include LlamaBotRails::AgentAuth
  before_action :set_book
  before_action :set_chapter
  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }

  llama_bot_allow :index, :create, :update, :destroy, :generate_image

  def index
    @pages = @chapter.pages.order(:id)

    respond_to do |format|
      format.html
      format.json {
        # Add page numbers to each page (1-indexed)
        pages_with_numbers = @pages.map.with_index(1) do |page, index|
          page.as_json.merge(page_number: index)
        end
        render json: pages_with_numbers
      }
    end
  end

  def new
    @page = @chapter.pages.new
  end

  def create
    @page = @chapter.pages.new(page_params)

    respond_to do |format|
      if @page.save

        format.html { redirect_to book_chapter_pages_path(@book, @chapter), notice: 'Page was successfully created.' }
        format.json { render json: @page, status: :created } # ✅ JSON success
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @page.errors, status: :unprocessable_entity } # ✅ JSON failure
      end
    end
  end

  def edit
    @page = @chapter.pages.find(params[:id])
  end

  def update
    @page = @chapter.pages.find(params[:id])
  
    respond_to do |format|
      if @page.update(page_params)
        format.html { redirect_to book_chapter_pages_path(@book, @chapter), notice: 'Page was successfully updated.' }
        format.json { render json: @page, status: :ok }  # ✅ JSON success
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @page.errors, status: :unprocessable_entity }  # ✅ JSON failure
      end
    end
  end

  def destroy
    @page = @chapter.pages.find(params[:id])
    if @page.destroy
      respond_to do |format|
        format.html { redirect_to book_chapter_pages_path(@book, @chapter), notice: 'Page was successfully deleted.' }
        format.json { render json: { message: 'Page was successfully deleted.', page: @page }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to book_chapter_pages_path(@book, @chapter), alert: 'Failed to delete page.' }
        format.json { render json: { errors: @page.errors }, status: :unprocessable_entity }
      end
    end
  end

  def generate_image
    @page = @chapter.pages.find(params[:id])
    generate_image_for_page(@page)
    respond_to do |format|
      format.html { redirect_to edit_book_chapter_page_path(@book, @chapter, @page), notice: 'Image generated and attached!' }
      format.json { render json: @page, status: :ok } # ✅ JSON image generation success
    end
  rescue => e
    respond_to do |format|
      format.html { redirect_to edit_book_chapter_page_path(@book, @chapter, @page), alert: "AI image generation failed: #{e.message}" }
      format.json { render json: { error: e.message }, status: :unprocessable_entity } # ✅ JSON failure
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

  def generate_image_for_page(page)
    book_title = @book.title.to_s.strip
    book_level = @book.reading_level.to_s.strip
    learning_objective = @book.learning_outcome.to_s.strip
    chapter_title = @chapter.title.to_s.strip
    previous_pages = @book.chapters.order(:id).map { |c| c.pages.order(:id).to_a }.flatten
                        .take_while { |p| p.id != page.id }.map(&:content).join("\n")

    page.generate_picture(
      replace_existing: true,
      book_title: book_title,
      book_level: book_level,
      learning_objective: learning_objective,
      previous_pages: previous_pages
    )
  end
end