require 'rails_helper'

RSpec.describe "Controversies", type: :request do
  let!(:controversy) { Controversy.create!(name: "Sample Controversy", bio: "This is a sample bio") }

  describe "GET /controversies" do
    it "returns a 200 OK status" do
      get "/controversies"
      expect(response).to have_http_status(:ok)
    end

    it "includes the name of the controversy" do
      get "/controversies"
      expect(response.body).to include("Sample Controversy")
    end
  end

  describe "GET /controversies/:id" do
    it "returns a 200 OK status" do
      get controversy_path(controversy)
      expect(response).to have_http_status(:ok)
    end

    it "includes the controversy details" do
      get controversy_path(controversy)
      expect(response.body).to include("Sample Controversy")
      expect(response.body).to include("This is a sample bio")
    end
  end
end
