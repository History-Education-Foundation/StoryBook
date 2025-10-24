class ChaptersController < ApplicationController
  include LlamaBotRails::ControllerExtensions
  include LlamaBotRails::AgentAuth
  before_action :set_book
  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }

  llama_bot_allow :index, :show, :create, :update, :destroy

  def index
    @chapters = @book.chapters.order(:created_at)

    respond_to do |format|
      format.html
      format.json { render json: @chapters }
    end
  end

  def show
    @chapter = @book.chapters.find(params[:id])
    respond_to do |format|
      format.json { render json: @chapter }
    end
  end

  def new
    @chapter = @book.chapters.new
  end

  def create
    @chapter = @book.chapters.new(chapter_params)

    respond_to do |format|
      if @chapter.save
        format.html { redirect_to book_chapters_path(@book), notice: 'Chapter was successfully created.' }
        format.json { render json: @chapter, status: :created } # ✅ JSON success
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @chapter.errors, status: :unprocessable_entity } # ✅ JSON failure
      end
    end
  end

  def edit
    @chapter = @book.chapters.find(params[:id])
  end

  def update
    @chapter = @book.chapters.find(params[:id])
  
    respond_to do |format|
      if @chapter.update(chapter_params)
        format.html { redirect_to book_chapters_path(@book), notice: 'Chapter was successfully updated.' }
        format.json { render json: @chapter, status: :ok }  # ✅ JSON success
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @chapter.errors, status: :unprocessable_entity }  # ✅ JSON failure
      end
    end
  end

  def destroy
    @chapter = @book.chapters.find(params[:id])
    if @chapter.destroy
      respond_to do |format|
        format.html { redirect_to book_chapters_path(@book), notice: 'Chapter was successfully deleted.' }
        format.json { render json: { message: 'Chapter was successfully deleted.', chapter: @chapter }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to book_chapters_path(@book), alert: 'Failed to delete chapter.' }
        format.json { render json: { errors: @chapter.errors }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_book
    @book = current_user.books.find(params[:book_id])
  end

  def chapter_params
    params.require(:chapter).permit(:title, :description)
  end
end