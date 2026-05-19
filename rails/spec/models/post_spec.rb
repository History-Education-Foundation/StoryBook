require 'rails_helper'

RSpec.describe Post, type: :model do
  describe "associations" do
    it "belongs to a user" do
      user = create(:user)
      post = create(:post, user: user)
      expect(post.user).to eq(user)
    end

    it "optionally belongs to a category" do
      post = build(:post, category: nil)
      expect(post).to be_valid
      
      category = Category.create!(name: "Test Category")
      post.category = category
      expect(post.category).to eq(category)
    end

    it "optionally belongs to an author" do
      post = build(:post, author: nil)
      expect(post).to be_valid

      author = Author.create!(name: "Test Author")
      post.author = author
      expect(post.author).to eq(author)
    end
  end

  describe "validations" do
    it "requires a user association" do
      post = build(:post, user: nil)
      expect(post).not_to be_valid
    end
  end

  describe "post creation" do
    it "creates a valid post with required attributes" do
      user = create(:user)
      post = create(:post, user: user)
      expect(post).to be_persisted
      expect(post.user).to eq(user)
    end

    it "creates a post with optional attributes" do
      user = create(:user)
      post = create(:post,
                   user: user,
                   title: "My First Post",
                   body: "This is the content of my post")
      expect(post.title).to eq("My First Post")
      expect(post.body.to_plain_text.strip).to eq("This is the content of my post")
    end

    it "cannot create a post without a user" do
      post = build(:post, user: nil)
      expect(post).not_to be_valid
    end
  end

  describe "relationships" do
    it "associates with a user" do
      user = create(:user)
      post = create(:post, user: user)
      expect(post.user).to eq(user)
    end

    it "can be deleted independently from user" do
      user = create(:user)
      post = create(:post, user: user)
      post.destroy
      expect(Post.find_by(id: post.id)).to be_nil
      expect(User.find_by(id: user.id)).to eq(user)
    end
  end

  describe "timestamps" do
    it "has created_at timestamp" do
      post = create(:post)
      expect(post.created_at).not_to be_nil
    end

    it "has updated_at timestamp" do
      post = create(:post)
      expect(post.updated_at).not_to be_nil
      post.update(title: "Updated Title")
      expect(post.updated_at).to be >= post.created_at
    end
  end

  describe "content fields" do
    it "requires a title" do
      user = create(:user)
      post = build(:post, user: user, title: nil)
      expect(post).not_to be_valid
    end

    it "requires a body" do
      user = create(:user)
      post = build(:post, user: user, body: nil)
      expect(post).not_to be_valid
    end

    it "is an instance of ActionText::RichText" do
      post = create(:post, body: "Hello world")
      expect(post.body).to be_an_instance_of(ActionText::RichText)
    end
  end

  describe "inline creation" do
    let(:user) { create(:user) }

    it "creates a new category inline" do
      post = Post.new(user: user, title: "Title", body: "Body", new_category_name: "Tech")
      expect { post.save }.to change(Category, :count).by(1)
      expect(post.category.name).to eq("Tech")
    end

    it "uses existing category if name matches" do
      category = Category.create!(name: "Tech")
      post = Post.new(user: user, title: "Title", body: "Body", new_category_name: "Tech")
      expect { post.save }.not_to change(Category, :count)
      expect(post.category).to eq(category)
    end

    it "creates a new author inline" do
      post = Post.new(user: user, title: "Title", body: "Body", new_author_name: "John Doe")
      expect { post.save }.to change(Author, :count).by(1)
      expect(post.author.name).to eq("John Doe")
    end

    it "uses existing author if name matches" do
      author = Author.create!(name: "John Doe")
      post = Post.new(user: user, title: "Title", body: "Body", new_author_name: "John Doe")
      expect { post.save }.not_to change(Author, :count)
      expect(post.author).to eq(author)
    end
  end
end
