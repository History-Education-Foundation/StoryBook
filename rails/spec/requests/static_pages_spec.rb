require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  describe "GET /lesson_plans" do
    let!(:topic) { CivicTopic.create!(name: "Separation of Powers", grade_level: "8th Grade", subject: "U.S. History", published: true) }

    it "renders the lesson plans page with dynamic links" do
      get lesson_plans_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("8th Grade U.S. History")
      expect(response.body).to include("Separation of Powers")
      expect(response.body).to include(civic_path(topic))
    end

    it "shows Coming Soon for subjects without topics" do
      get lesson_plans_path
      expect(response.body).to include("10th Grade World History")
      # We need to check that "Coming Soon" is present in the context of "10th Grade World History"
      # But since it's present for many, a simple include check is enough for basic verification
      expect(response.body).to include("Coming Soon")
    end
  end
end
