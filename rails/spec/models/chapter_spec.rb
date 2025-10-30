require 'rails_helper'

RSpec.describe Chapter, type: :model do
  describe "associations" do
    it "belongs to a book" do
      book = create(:book)
      chapter = create(:chapter, book: book)
      expect(chapter.book).to eq(book)
    end

    it "has many pages with dependent destroy" do
      chapter = create(:chapter)
      page = create(:page, chapter: chapter)
      chapter.destroy
      expect(Page.find_by(id: page.id)).to be_nil
    end
  end

  describe "validations" do
    it "requires a book association" do
      chapter = build(:chapter, book: nil)
      expect(chapter).not_to be_valid
    end
  end

  describe "chapter creation" do
    it "creates a valid chapter with required attributes" do
      book = create(:book)
      chapter = create(:chapter, book: book)
      expect(chapter).to be_persisted
      expect(chapter.book).to eq(book)
    end

    it "creates a chapter with optional attributes" do
      book = create(:book)
      chapter = create(:chapter, 
                      book: book,
                      title: "Introduction",
                      description: "An intro to the topic")
      expect(chapter.title).to eq("Introduction")
      expect(chapter.description).to eq("An intro to the topic")
    end

    it "cannot create a chapter without a book" do
      chapter = build(:chapter, book: nil)
      expect(chapter).not_to be_valid
    end
  end

  describe "relationships" do
    it "associates with a book" do
      book = create(:book)
      chapter = create(:chapter, book: book)
      expect(chapter.book).to eq(book)
    end

    it "can have many pages" do
      chapter = create(:chapter)
      page1 = create(:page, chapter: chapter)
      page2 = create(:page, chapter: chapter)
      expect(chapter.pages).to include(page1, page2)
    end

    it "destroys pages when deleted" do
      chapter = create(:chapter)
      page = create(:page, chapter: chapter)
      chapter.destroy
      expect(Page.find_by(id: page.id)).to be_nil
    end
  end

  describe "timestamps" do
    it "has created_at timestamp" do
      chapter = create(:chapter)
      expect(chapter.created_at).not_to be_nil
      expect(chapter.created_at).to be_a(ActiveSupport::TimeWithZone)
    end

    it "has updated_at timestamp" do
      chapter = create(:chapter)
      expect(chapter.updated_at).not_to be_nil
      chapter.update(title: "Updated")
      expect(chapter.updated_at).to be > chapter.created_at
    end
  end
end
