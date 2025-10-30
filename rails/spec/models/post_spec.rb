require 'rails_helper'

RSpec.describe Post, type: :model do
  describe "associations" do
    it "belongs to a user" do
      user = create(:user)
      post = create(:post, user: user)
      expect(post.user).to eq(user)
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
      expect(post.body).to eq("This is the content of my post")
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
    it "accepts nil title" do
      user = create(:user)
      post = create(:post, user: user, title: nil)
      expect(post.title).to be_nil
    end

    it "accepts nil body" do
      user = create(:user)
      post = create(:post, user: user, body: nil)
      expect(post.body).to be_nil
    end

    it "accepts long body content" do
      user = create(:user)
      long_body = "A" * 10000
      post = create(:post, user: user, body: long_body)
      expect(post.body).to eq(long_body)
    end
  end
end
