require 'rails_helper'

RSpec.describe "Posts", type: :request do
  describe "GET /posts" do
    it "returns http success for guests" do
      create(:post, status: :published)
      get posts_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Our Blog")
    end

    it "shows only published posts for guests" do
      published_post = create(:post, status: :published, title: "Published Post")
      draft_post = create(:post, status: :draft, title: "Draft Post")
      get posts_path
      expect(response.body).to include("Published Post")
      expect(response.body).not_to include("Draft Post")
    end

    it "shows own draft posts and published posts for logged in users" do
      user = create(:user)
      sign_in user
      own_draft = create(:post, user: user, status: :draft, title: "My Draft")
      other_draft = create(:post, status: :draft, title: "Other Draft")
      other_published = create(:post, status: :published, title: "Other Published")
      
      get posts_path
      expect(response.body).to include("My Draft")
      expect(response.body).to include("Other Published")
      expect(response.body).not_to include("Other Draft")
    end
  end

  describe "PATCH /posts/:id" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:my_post) { create(:post, user: user) }
    let(:other_post) { create(:post, user: other_user) }

    context "when owner" do
      before { sign_in user }

      it "updates the post and redirects to show" do
        patch post_path(my_post), params: { post: { title: "Updated Title" } }
        expect(response).to redirect_to(post_path(my_post))
        expect(my_post.reload.title).to eq("Updated Title")
      end

      it "returns turbo stream response when requested" do
        patch post_path(my_post), params: { post: { title: "Turbo Title" } }, as: :turbo_stream
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        expect(response.body).to include("turbo-stream action=\"replace\"")
      end

      it "can update status" do
        patch post_path(my_post), params: { post: { status: "published" } }
        expect(my_post.reload.status).to eq("published")
      end
    end

    context "when not owner" do
      before { sign_in user }

      it "raises Pundit::NotAuthorizedError" do
        expect {
          patch post_path(other_post), params: { post: { title: "Hack" } }
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "DELETE /posts/:id" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let!(:my_post) { create(:post, user: user) }
    let!(:other_post) { create(:post, user: other_user) }

    context "when owner" do
      before { sign_in user }

      it "deletes the post" do
        expect {
          delete post_path(my_post)
        }.to change(Post, :count).by(-1)
        expect(response).to redirect_to(posts_path)
      end

      it "returns turbo stream response when requested" do
        delete post_path(my_post), as: :turbo_stream
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        expect(response.body).to include("turbo-stream action=\"remove\"")
      end
    end

    context "when not owner" do
      before { sign_in user }

      it "raises Pundit::NotAuthorizedError" do
        expect {
          delete post_path(other_post)
        }.to raise_error(Pundit::NotAuthorizedError)
      end
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
