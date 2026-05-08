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
end
