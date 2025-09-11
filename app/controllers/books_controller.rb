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
    @book.status = "Draft" # Always start as draft, ignore param
    if @book.save
      redirect_to books_path, notice: 'Book was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @book = current_user.books.find(params[:id])
    if @book.status == "Published"
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
    if current_user.student?
      @books = current_user.saved_books_library.where(status: 'Published')
    elsif current_user.staff?
      created_books = current_user.books.where(status: 'Published')
      saved_books = current_user.saved_books_library.where(status: 'Published')
      @books = (created_books + saved_books).uniq
    else
      redirect_to books_path, alert: 'My Library is only for students or staff.' and return
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

    # Gather text: book title, chapters, descriptions, and page content
    text_blocks = []
    text_blocks << @book.title
    @book.chapters.order(:id).includes(:pages).each do |chapter|
      text_blocks << chapter.title
      text_blocks << chapter.description.to_s if chapter.description.present?
      chapter.pages.order(:id).each do |page|
        text_blocks << page.content.to_s if page.content.present?
      end
    end
    full_text = text_blocks.join("\n\n")

    begin
      audio_file = OpenAi.new.generate_audio(full_text)
      send_data audio_file.read, type: 'audio/mpeg', disposition: 'inline', filename: "book-#{@book.id}.mp3"
    rescue => e
      render json: { error: "Audio generation failed: #{e.message}" }, status: :internal_server_error
    end
  end


def publish
  @book = current_user.books.find(params[:id])
  if @book.status == "Draft"
    # Generate audio and save path before publishing
    audio_path = nil
    begin
      text_blocks = []
      text_blocks << @book.title
      @book.chapters.order(:id).includes(:pages).each do |chapter|
        text_blocks << chapter.title
        text_blocks << chapter.description.to_s if chapter.description.present?
        chapter.pages.order(:id).each do |page|
          text_blocks << page.content.to_s if page.content.present?
        end
      end
      full_text = text_blocks.join("\n\n")
      audio_file = OpenAi.new.generate_audio(full_text)
      # Directory where audio files are stored
      audio_dir = Rails.root.join("public", "book_audio")
      FileUtils.mkdir_p(audio_dir)
      filename = "book-#{@book.id}.mp3"
      full_audio_path = audio_dir.join(filename)
      File.binwrite(full_audio_path, audio_file.read)
      audio_path = "/book_audio/#{filename}"
    rescue => e
      Rails.logger.error("Audio generation failed at publish: #{e.message}")
      audio_path = nil # No audio saved if failed
    end
    @book.update(status: "Published", audio: audio_path)
    redirect_to edit_book_path(@book), notice: "Book published successfully."
  else
    redirect_to edit_book_path(@book), alert: "Only drafts can be published."
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

private

  def book_params
    params.require(:book).permit(:title, :learning_outcome, :reading_level, :status)
  end
end
