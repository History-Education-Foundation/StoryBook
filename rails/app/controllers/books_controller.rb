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
    @book.status = "Draft"
    if @book.save
      redirect_to books_path, notice: 'Book was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @book = current_user.books.find(params[:id])
    if @book.status == "Published" && params[:from_publish].blank?
      redirect_to books_path, alert: "You cannot edit published books."
    end
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
    filter = params[:filter]
    if filter == "liked"
      @books = current_user.saved_books_library.where(status: 'Published')
    else
      @books = Book.where(status: 'Published')
    end
  end

  def reader
    @book = Book.find(params[:id])
    allowed =
      (current_user.student? && current_user.saved_books_library.exists?(id: @book.id)) ||
      (current_user.staff? && current_user.books.exists?(id: @book.id))
    unless allowed
      redirect_to books_path, alert: 'You must save this book to your library before reading.' and return
    end
    @chapters = @book.chapters.includes(:pages).order(:id)
    @chapters.each { |chapter| chapter.pages.with_attached_image.load }
  end

  def audio_playlist
    @book = Book.find(params[:id])
    allowed =
      (current_user.student? && current_user.saved_books_library.exists?(id: @book.id)) ||
      (current_user.staff? && current_user.books.exists?(id: @book.id))
    unless allowed
      render json: { error: 'Not authorized' }, status: :unauthorized and return
    end
    unless @book.status == 'Published'
      render json: { error: 'Audio playlist is only available for published books.' }, status: :forbidden and return
    end
    playlist = []
    @book.chapters.order(:id).each do |chapter|
      chapter.pages.order(:id).each do |page|
        if page.audio_file.attached?
          playlist << {
            page_id: page.id,
            url: helpers.url_for(page.audio_file)
          }
        end
      end
    end
    render json: { audios: playlist }
  end

  # ... rest of controller unchanged ...

  def generate_audio
    @book = Book.find(params[:id])
    allowed = (current_user.student? && current_user.saved_books_library.exists?(id: @book.id)) ||
      (current_user.staff? && current_user.books.exists?(id: @book.id))
    unless allowed
      render json: { error: 'Not authorized' }, status: :unauthorized and return
    end
    unless @book.status == 'Published'
      render json: { error: 'Audio generation is only available for published books.' }, status: :forbidden and return
    end
    if @book.audio_file.attached?
      send_data @book.audio_file.download, type: @book.audio_file.content_type, disposition: 'inline', filename: @book.audio_file.filename.to_s
      return
    end
    render json: { error: 'Full book audio not available yet for this book.' }, status: :not_found
  end

  def publish
    @book = current_user.books.find(params[:id])
    if @book.status == "Draft" || @book.status == "Archived"
      audio_path = nil
      begin
        @book.chapters.order(:id).includes(:pages).each do |chapter|
          chapter.pages.order(:id).each do |page|
            begin
              if page.content.present?
                content_for_audio = page.content
                if page.this_is_first_page_and_first_chapter?
                  content_for_audio = "#{@book.title.strip}. #{chapter.title.strip}. #{page.content.strip}"
                elsif page.this_is_first_page_in_chapter?
                  content_for_audio = "#{chapter.title.strip}. #{page.content.strip}"
                end
                OpenAi.new.generate_audio(content_for_audio, attach_to: page, attachment_name: :audio_file)
              end
            rescue => e
              Rails.logger.error("Audio generation failed for Page \\#{page.id}: \\#{e.message}")
            end
          end
        end
        audio_path = nil
        @book.generate_full_audio
      rescue => e
        Rails.logger.error("Audio generation failed at publish: #{e.message}")
        audio_path = nil
      end
      @book.update(status: "Published", audio: audio_path)
      redirect_to books_path, notice: "Book published successfully."
    else
      redirect_to edit_book_path(@book), alert: "Only draft or archived books can be published."
    end
  end

  def archive
    @book = current_user.books.find(params[:id])
    if @book.status == "Published"
      @book.update(status: "Archived")
      redirect_to books_path, notice: "Book archived successfully."
    else
      redirect_to books_path, alert: "Only published books can be archived."
    end
  end

  def unarchive
    @book = current_user.books.find(params[:id])
    if @book.status == "Archived"
      @book.update(status: "Draft")
      redirect_to books_path, notice: "Book was restored to draft."
    else
      redirect_to books_path, alert: "Only archived books can be unarchived."
    end
  end

  def generate_all_pictures
    @book = current_user.books.find(params[:id])
    result = @book.generate_all_pictures
    flash[:notice] = "Batch image generation complete: #{result[:generated]} images generated, #{result[:failed]} failed, #{result[:skipped]} skipped, out of #{result[:total]} pages. See logs for details."
    redirect_to book_chapters_path(@book)
  end

  def retry_failed_pictures
    @book = current_user.books.find(params[:id])
    result = @book.retry_failed_pictures
    flash[:notice] = "Retry complete: #{result[:generated]} images generated, #{result[:failed]} still failed, out of #{result[:total]} retried pages."
    redirect_to book_chapters_path(@book)
  end

  private

  def book_params
    params.require(:book).permit(:title, :learning_outcome, :reading_level, :status)
  end
end
