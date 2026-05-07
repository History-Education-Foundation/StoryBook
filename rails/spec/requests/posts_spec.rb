require 'rails_helper'

RSpec.describe "Admin::Posts", type: :request do
  let(:admin) { User.create!(email: "admin_post@example.com", password: "password", role: "admin") }
  let(:category) { Category.create!(name: "Tech") }
  let(:author) { Author.create!(name: "John Doe") }
  let(:post_record) { Post.create!(title: "Hello World", body: "Content", user: admin, category: category, author: author) }

  describe "POST /admin/posts" do
    before { sign_in admin }

    context "with valid parameters" do
      it "creates a new Post with category and author and responds with turbo_stream" do
        expect {
          post admin_posts_path, params: { 
            post: { 
              title: "New Post", 
              body: "Body", 
              category_id: category.id, 
              author_id: author.id 
            } 
          }, as: :turbo_stream
        }.to change(Post, :count).by(1)
        
        new_post = Post.last
        expect(new_post.category).to eq(category)
        expect(new_post.author).to eq(author)
        expect(response.media_type).to eq "text/vnd.turbo-stream.html"
        expect(response.body).to include("turbo-stream")
        expect(response.body).to include("prepend")
        expect(response.body).to include("posts")
      end
    end
  end

  describe "PATCH /admin/posts/:id" do
    before { sign_in admin }

    it "updates the post and responds with turbo_stream" do
      patch admin_post_path(post_record), params: { post: { title: "Updated Title" } }, as: :turbo_stream
      expect(post_record.reload.title).to eq "Updated Title"
      expect(response.media_type).to eq "text/vnd.turbo-stream.html"
      expect(response.body).to include("turbo-stream")
      expect(response.body).to include("replace")
    end
  end

  describe "DELETE /admin/posts/:id" do
    before { sign_in admin }

    it "destroys the post and responds with turbo_stream" do
      post_to_delete = Post.create!(title: "Delete Me", body: "...", user: admin)
      expect {
        delete admin_post_path(post_to_delete), as: :turbo_stream
      }.to change(Post, :count).by(-1)
      expect(response.media_type).to eq "text/vnd.turbo-stream.html"
      expect(response.body).to include("turbo-stream")
      expect(response.body).to include("remove")
    end
  end

  describe "GET /admin/posts" do
    before { sign_in admin }

    it "loads posts, categories and authors" do
      get admin_posts_path
      expect(response).to be_successful
      expect(assigns(:posts)).to include(post_record)
      expect(assigns(:categories)).to include(category)
      expect(assigns(:authors)).to include(author)
    end
  end
end
