require 'rails_helper'

RSpec.describe "Posts", type: :request do
  describe "GET /posts" do
    it "returns http success for guests" do
      create(:post)
      get posts_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Our Blog")
    end
  end

  describe "GET /posts/:id" do
    it "returns http success for guests" do
      post = create(:post)
      get post_path(post)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(post.title)
    end
  end

  describe "GET /posts/new" do
    context "when guest" do
      it "redirects to login" do
        get new_post_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in" do
      it "returns http success" do
        user = create(:user)
        sign_in user
        get new_post_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Create New Post")
      end
    end
  end

  describe "POST /posts" do
    let(:valid_params) { { post: { title: "New Title", body: "New Body" } } }

    context "when guest" do
      it "redirects to login and does not create post" do
        expect {
          post posts_path, params: valid_params
        }.not_to change(Post, :count)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in" do
      it "creates a new post and redirects to index" do
        user = create(:user)
        sign_in user
        expect {
          post posts_path, params: valid_params
        }.to change(Post, :count).by(1)
        expect(response).to redirect_to(posts_path)
        expect(Post.last.user).to eq(user)
      end

      it "creates a post with a new category and author inline" do
        user = create(:user)
        sign_in user
        params = {
          post: {
            title: "New Title",
            body: "<div>Rich Content</div>",
            new_category_name: "Innovation",
            new_author_name: "Jane Smith"
          }
        }
        expect {
          post posts_path, params: params
        }.to change(Post, :count).by(1)
         .and change(Category, :count).by(1)
         .and change(Author, :count).by(1)
        
        post = Post.last
        expect(post.category.name).to eq("Innovation")
        expect(post.author.name).to eq("Jane Smith")
        expect(post.body.to_s).to include("Rich Content")
      end

      it "returns unprocessable_entity for invalid params" do
        user = create(:user)
        sign_in user
        post posts_path, params: { post: { title: "", body: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
