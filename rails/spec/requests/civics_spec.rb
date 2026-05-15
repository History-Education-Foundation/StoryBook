require 'rails_helper'

RSpec.describe "Civics", type: :request do
  let!(:civic_topic) { CivicTopic.create!(name: "Andrew Yang", bio: "Former presidential candidate", published: true) }

  describe "GET /civics" do
    it "returns a success response and lists civic topics" do
      get civics_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Andrew Yang")
    end
  end

  describe "GET /civics/:id" do
    it "returns a success response for a valid civic topic" do
      get civic_path(civic_topic)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Andrew Yang")
    end
  end
end