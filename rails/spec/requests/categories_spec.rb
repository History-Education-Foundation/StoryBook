require 'rails_helper'

RSpec.describe "Admin::Categories", type: :request do
  let(:admin) { User.create!(email: "admin@example.com", password: "password", role: "admin") }
  let(:user) { User.create!(email: "user@example.com", password: "password", role: "staff") }
  let(:category) { Category.create!(name: "General") }

  describe "Access Control" do
    it "redirects non-admins to root" do
      sign_in user
      get admin_categories_path
      expect(response).to redirect_to(root_path)
    end

    it "allows admins to access index" do
      sign_in admin
      get admin_categories_path
      expect(response).to be_successful
    end
  end

  describe "POST /admin/categories" do
    before { sign_in admin }

    context "with valid parameters" do
      it "creates a new Category and responds with turbo_stream" do
        expect {
          post admin_categories_path, params: { category: { name: "New Category" } }, as: :turbo_stream
        }.to change(Category, :count).by(1)
        expect(response.media_type).to eq "text/vnd.turbo-stream.html"
        expect(response.body).to include("turbo-stream")
        expect(response.body).to include("prepend")
        expect(response.body).to include("categories")
      end
    end
  end

  describe "PATCH /admin/categories/:id" do
    before { sign_in admin }

    it "updates the category and responds with turbo_stream" do
      patch admin_category_path(category), params: { category: { name: "Updated" } }, as: :turbo_stream
      expect(category.reload.name).to eq "Updated"
      expect(response.media_type).to eq "text/vnd.turbo-stream.html"
      expect(response.body).to include("turbo-stream")
      expect(response.body).to include("replace")
    end
  end

  describe "DELETE /admin/categories/:id" do
    before { sign_in admin }

    it "destroys the category and responds with turbo_stream" do
      category_to_delete = Category.create!(name: "Delete Me")
      expect {
        delete admin_category_path(category_to_delete), as: :turbo_stream
      }.to change(Category, :count).by(-1)
      expect(response.media_type).to eq "text/vnd.turbo-stream.html"
      expect(response.body).to include("turbo-stream")
      expect(response.body).to include("remove")
    end
  end
end
