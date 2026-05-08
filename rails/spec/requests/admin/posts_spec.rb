require 'rails_helper'

RSpec.describe "Admin::Posts", type: :request do
  describe "GET /admin/posts" do
    it "redirects guests to root or login" do
      get admin_posts_path
      expect(response).to have_http_status(:redirect)
    end
  end
end
