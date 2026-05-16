require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  describe "GET /lesson_plans" do
    it "returns http success" do
      get "/lesson_plans"
      expect(response).to have_http_status(:success)
    end

    it "contains the expected lesson plan subjects" do
      get "/lesson_plans"
      expect(response.body).to include("8th Grade U.S. History")
      expect(response.body).to include("10th Grade World History")
      expect(response.body).to include("11th Grade U.S. History")
      expect(response.body).to include("Financial Literacy")
      expect(response.body).to include("World Geography")
      expect(response.body).to include("U.S Government")
      expect(response.body).to include("Psychology")
      expect(response.body).to include("NBCT Study Standards")
      expect(response.body).to include("NBCT Standards Ages 7-10")
      expect(response.body).to include("Digital Literacy")
      expect(response.body).to include("Student Leaders")
    end
  end
end
