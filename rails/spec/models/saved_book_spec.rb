require 'rails_helper'

RSpec.describe SavedBook, type: :model do
  describe "associations" do
    it "belongs to a user" do
      user = create(:user)
      book = create(:book)
      saved_book = create(:saved_book, user: user, book: book)
      expect(saved_book.user).to eq(user)
    end

    it "belongs to a book" do
      user = create(:user)
      book = create(:book)
      saved_book = create(:saved_book, user: user, book: book)
      expect(saved_book.book).to eq(book)
    end
  end

  describe "validations" do
    it "requires a user association" do
      saved_book = build(:saved_book, user: nil)
      expect(saved_book).not_to be_valid
    end

    it "requires a book association" do
      saved_book = build(:saved_book, book: nil)
      expect(saved_book).not_to be_valid
    end
  end

  describe "saved book creation" do
    it "creates a valid saved book with required associations" do
      user = create(:user)
      book = create(:book)
      saved_book = create(:saved_book, user: user, book: book)
      expect(saved_book).to be_persisted
      expect(saved_book.user).to eq(user)
      expect(saved_book.book).to eq(book)
    end

    it "cannot create a saved book without a user" do
      book = create(:book)
      saved_book = build(:saved_book, user: nil, book: book)
      expect(saved_book).not_to be_valid
    end

    it "cannot create a saved book without a book" do
      user = create(:user)
      saved_book = build(:saved_book, user: user, book: nil)
      expect(saved_book).not_to be_valid
    end
  end

  describe "relationships" do
    it "associates with a user" do
      user = create(:user)
      book = create(:book)
      saved_book = create(:saved_book, user: user, book: book)
      expect(saved_book.user).to eq(user)
    end

    it "associates with a book" do
      user = create(:user)
      book = create(:book)
      saved_book = create(:saved_book, user: user, book: book)
      expect(saved_book.book).to eq(book)
    end

    it "allows a user to save multiple books" do
      user = create(:user)
      book1 = create(:book)
      book2 = create(:book)
      saved_book1 = create(:saved_book, user: user, book: book1)
      saved_book2 = create(:saved_book, user: user, book: book2)
      
      expect(user.saved_books).to include(saved_book1, saved_book2)
      expect(user.saved_books_library).to include(book1, book2)
    end

    it "allows a book to be saved by multiple users" do
      book = create(:book)
      user1 = create(:user)
      user2 = create(:user)
      saved_book1 = create(:saved_book, user: user1, book: book)
      saved_book2 = create(:saved_book, user: user2, book: book)
      
      expect(book.saved_books).to include(saved_book1, saved_book2)
      expect(book.saved_by_users).to include(user1, user2)
    end
  end

  describe "timestamps" do
    it "has created_at timestamp" do
      saved_book = create(:saved_book)
      expect(saved_book.created_at).not_to be_nil
    end

    it "has updated_at timestamp" do
      saved_book = create(:saved_book)
      expect(saved_book.updated_at).not_to be_nil
    end
  end

  describe "user-book relationship uniqueness" do
    it "allows creating multiple different saved books" do
      user = create(:user)
      book1 = create(:book)
      book2 = create(:book)
      
      saved_book1 = create(:saved_book, user: user, book: book1)
      saved_book2 = create(:saved_book, user: user, book: book2)
      
      expect(SavedBook.count).to eq(2)
      expect(saved_book1).to be_persisted
      expect(saved_book2).to be_persisted
    end

    it "allows different users to save the same book" do
      book = create(:book)
      user1 = create(:user)
      user2 = create(:user)
      
      saved_book1 = create(:saved_book, user: user1, book: book)
      saved_book2 = create(:saved_book, user: user2, book: book)
      
      expect(SavedBook.count).to eq(2)
      expect(saved_book1).to be_persisted
      expect(saved_book2).to be_persisted
    end
  end
end
