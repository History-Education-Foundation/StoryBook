require 'rails_helper'

RSpec.describe Page, type: :model do
  describe "associations" do
    it "belongs to a chapter" do
      chapter = create(:chapter)
      page = create(:page, chapter: chapter)
      expect(page.chapter).to eq(chapter)
    end
  end

  describe "attachments" do
    it "responds to has_one_attached" do
      page = create(:page)
      # Image attachment is configured in the model
      expect(page).to respond_to(:image)
    end
  end

  describe "validations" do
    it "requires a chapter association" do
      page = build(:page, chapter: nil)
      expect(page).not_to be_valid
    end
  end

  describe "page creation" do
    it "creates a valid page with required attributes" do
      chapter = create(:chapter)
      page = create(:page, chapter: chapter)
      expect(page).to be_persisted
      expect(page.chapter).to eq(chapter)
    end

    it "creates a page with optional attributes" do
      chapter = create(:chapter)
      page = create(:page,
                   chapter: chapter,
                   content: "This is page content")
      expect(page.content).to eq("This is page content")
    end

    it "cannot create a page without a chapter" do
      page = build(:page, chapter: nil)
      expect(page).not_to be_valid
    end
  end

  describe "relationships" do
    it "associates with a chapter" do
      chapter = create(:chapter)
      page = create(:page, chapter: chapter)
      expect(page.chapter).to eq(chapter)
    end

    it "indirectly associates with a book through chapter" do
      book = create(:book)
      chapter = create(:chapter, book: book)
      page = create(:page, chapter: chapter)
      expect(page.chapter.book).to eq(book)
    end

    it "can be deleted independently from chapter" do
      chapter = create(:chapter)
      page = create(:page, chapter: chapter)
      page.destroy
      expect(Page.find_by(id: page.id)).to be_nil
      expect(Chapter.find_by(id: chapter.id)).to eq(chapter)
    end
  end

  describe "timestamps" do
    it "has created_at timestamp" do
      page = create(:page)
      expect(page.created_at).not_to be_nil
    end

    it "has updated_at timestamp" do
      page = create(:page)
      expect(page.updated_at).not_to be_nil
      page.update(content: "Updated content")
      expect(page.updated_at).to be >= page.created_at
    end
  end

  describe "content field" do
    it "accepts nil content" do
      chapter = create(:chapter)
      page = create(:page, chapter: chapter, content: nil)
      expect(page.content).to be_nil
    end

    it "accepts long content" do
      chapter = create(:chapter)
      long_content = "A" * 50000
      page = create(:page, chapter: chapter, content: long_content)
      expect(page.content).to eq(long_content)
    end
  end

  describe "image attachment" do
    it "can have an attached image" do
      page = create(:page)
      image = fixture_file_upload('sample_image.jpg', 'image/jpeg')
      page.image.attach(image)
      expect(page.image.attached?).to be_truthy
    end

    it "can have multiple versions or no image" do
      chapter = create(:chapter)
      page1 = create(:page, chapter: chapter)
      page2 = create(:page, chapter: chapter)
      expect(page1.image.attached?).to be_falsey
      expect(page2.image.attached?).to be_falsey
    end
  end
end
