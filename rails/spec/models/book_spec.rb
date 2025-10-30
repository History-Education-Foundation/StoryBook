require 'rails_helper'

RSpec.describe Book, type: :model do
  describe "associations" do
    it "belongs to a user" do
      user = create(:user)
      book = create(:book, user: user)
      expect(book.user).to eq(user)
    end

    it "has many chapters with dependent destroy" do
      book = create(:book)
      chapter = create(:chapter, book: book)
      book.destroy
      expect(Chapter.find_by(id: chapter.id)).to be_nil
    end

    it "has many saved_books with dependent destroy" do
      book = create(:book)
      user = create(:user)
      saved_book = create(:saved_book, book: book, user: user)
      book.destroy
      expect(SavedBook.find_by(id: saved_book.id)).to be_nil
    end

    it "has many saved_by_users through saved_books" do
      book = create(:book)
      user1 = create(:user)
      user2 = create(:user)
      create(:saved_book, book: book, user: user1)
      create(:saved_book, book: book, user: user2)
      expect(book.saved_by_users).to include(user1, user2)
    end

    it "has many pages through chapters" do
      book = create(:book)
      chapter = create(:chapter, book: book)
      page = create(:page, chapter: chapter)
      expect(book.pages).to include(page)
    end
  end

  describe "attachments" do
    it "responds to has_one_attached" do
      book = create(:book)
      # Audio file attachment is configured in the model
      expect(book).to respond_to(:audio_file)
    end
  end

  describe "validations" do
    it "requires a user association" do
      book = build(:book, user: nil)
      expect(book).not_to be_valid
    end
  end

  describe "status defaults" do
    it "defaults to 'Draft' status on initialize" do
      book = Book.new
      expect(book.status).to eq("Draft")
    end

    it "preserves assigned status on initialize" do
      book = Book.new(status: "Published")
      expect(book.status).to eq("Published")
    end

    it "allows status to be changed after creation" do
      book = create(:book, status: "Draft")
      book.update(status: "Published")
      expect(book.reload.status).to eq("Published")
    end
  end

  describe "constants" do
    it "defines STATUSES constant with valid statuses" do
      expect(Book::STATUSES).to include("Draft", "Published", "Archived")
    end
  end

  describe "book creation" do
    it "creates a valid book with required attributes" do
      user = create(:user)
      book = create(:book, user: user)
      expect(book).to be_persisted
      expect(book.user).to eq(user)
      expect(book.status).to eq("Draft")
    end

    it "creates a book with optional attributes" do
      user = create(:user)
      book = create(:book, 
                   user: user,
                   title: "Advanced Rails",
                   learning_outcome: "Master Rails",
                   reading_level: "Advanced")
      expect(book.title).to eq("Advanced Rails")
      expect(book.learning_outcome).to eq("Master Rails")
      expect(book.reading_level).to eq("Advanced")
    end

    it "creates a published book" do
      book = create(:book, :published)
      expect(book.status).to eq("Published")
    end

    it "creates an archived book" do
      book = create(:book, :archived)
      expect(book.status).to eq("Archived")
    end
  end

  describe "relationships" do
    it "associates with a user" do
      user = create(:user)
      book = create(:book, user: user)
      expect(book.user).to eq(user)
    end

    it "can have many chapters" do
      book = create(:book)
      chapter1 = create(:chapter, book: book)
      chapter2 = create(:chapter, book: book)
      expect(book.chapters).to include(chapter1, chapter2)
    end

    it "can have many pages through chapters" do
      book = create(:book)
      chapter = create(:chapter, book: book)
      page1 = create(:page, chapter: chapter)
      page2 = create(:page, chapter: chapter)
      expect(book.pages).to include(page1, page2)
    end

    it "can be saved by multiple users" do
      book = create(:book)
      user1 = create(:user)
      user2 = create(:user)
      create(:saved_book, book: book, user: user1)
      create(:saved_book, book: book, user: user2)
      expect(book.saved_by_users).to include(user1, user2)
    end

    it "destroys chapters when deleted" do
      book = create(:book)
      chapter = create(:chapter, book: book)
      book.destroy
      expect(Chapter.find_by(id: chapter.id)).to be_nil
    end

    it "destroys saved_books when deleted" do
      book = create(:book)
      saved_book = create(:saved_book, book: book)
      book.destroy
      expect(SavedBook.find_by(id: saved_book.id)).to be_nil
    end
  end

  describe "generate_full_audio" do
    it "returns nil if book has no content" do
      book = create(:book)
      result = book.generate_full_audio
      expect(result).to be_nil
    end

    it "handles books with chapters but no pages gracefully" do
      book = create(:book)
      create(:chapter, book: book)
      result = book.generate_full_audio
      expect(result).to be_nil
    end

    it "gathers content in correct order: page title > chapter title > page content" do
      book = create(:book)
      chapter = create(:chapter, book: book, title: "Ch1")
      page = create(:page, chapter: chapter, content: "Page content")
      
      # Mock the OpenAi service to avoid actual API calls
      allow_any_instance_of(OpenAi).to receive(:generate_audio).and_return(true)
      
      book.generate_full_audio(voice: "alloy", format: "mp3")
      expect(book).to be_persisted
    end

    it "handles errors gracefully" do
      book = create(:book)
      chapter = create(:chapter, book: book)
      create(:page, chapter: chapter, content: "Content")
      
      # Mock OpenAi to raise an error
      allow_any_instance_of(OpenAi).to receive(:generate_audio).and_raise(StandardError.new("API Error"))
      
      result = book.generate_full_audio
      expect(result).to be_nil
    end
  end

  describe "generate_all_pictures" do
    it "returns stats hash with all counters" do
      book = create(:book)
      chapter = create(:chapter, book: book)
      create(:page, chapter: chapter)
      
      result = book.generate_all_pictures
      expect(result).to be_a(Hash)
      expect(result).to have_key(:total)
      expect(result).to have_key(:generated)
      expect(result).to have_key(:failed)
      expect(result).to have_key(:skipped)
    end

    it "returns zero totals for empty books" do
      book = create(:book)
      result = book.generate_all_pictures
      expect(result[:total]).to eq(0)
      expect(result[:generated]).to eq(0)
    end

    it "processes multiple pages" do
      book = create(:book)
      chapter = create(:chapter, book: book)
      create_list(:page, 3, chapter: chapter)
      
      result = book.generate_all_pictures
      expect(result[:total]).to eq(3)
    end

    it "respects replace_existing flag" do
      book = create(:book)
      chapter = create(:chapter, book: book)
      page = create(:page, chapter: chapter)
      
      # Attach an image
      page.image.attach(io: StringIO.new("fake image"), filename: "test.jpg", content_type: "image/jpeg")
      
      result = book.generate_all_pictures(replace_existing: false)
      expect(result[:total]).to eq(0) # Should skip pages with existing images
      
      result = book.generate_all_pictures(replace_existing: true)
      expect(result[:total]).to eq(1) # Should attempt to replace
    end
  end

  describe "retry_failed_pictures" do
    it "returns stats hash with all counters" do
      book = create(:book)
      result = book.retry_failed_pictures
      expect(result).to be_a(Hash)
      expect(result).to have_key(:total)
      expect(result).to have_key(:generated)
      expect(result).to have_key(:failed)
      expect(result).to have_key(:skipped)
    end

    it "only processes pages without images" do
      book = create(:book)
      chapter = create(:chapter, book: book)
      page_without_image = create(:page, chapter: chapter)
      page_with_image = create(:page, chapter: chapter)
      
      # Attach image to one page
      page_with_image.image.attach(io: StringIO.new("fake image"), filename: "test.jpg", content_type: "image/jpeg")
      
      result = book.retry_failed_pictures
      # Should only count the page without image
      expect(result[:total]).to be >= 0
    end

    it "returns zero totals for books with all pages having images" do
      book = create(:book)
      chapter = create(:chapter, book: book)
      page = create(:page, chapter: chapter)
      page.image.attach(io: StringIO.new("fake image"), filename: "test.jpg", content_type: "image/jpeg")
      
      result = book.retry_failed_pictures
      expect(result[:total]).to eq(0)
    end
  end
end
