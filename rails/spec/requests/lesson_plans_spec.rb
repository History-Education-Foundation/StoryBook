require 'rails_helper'

RSpec.describe "LessonPlans", type: :request do
  describe "GET /lesson_plan/20" do
    let!(:lesson_plan) do
      CivicTopic.find_or_create_by!(id: 20) do |t|
        t.name = "Taxes & Retirement"
        t.subject = "Financial Literacy"
        t.bio = "Lesson Overview"
        t.contributions = "Standard 1: Taxes\nStandard 2: Retirement"
        t.legacy = "PART 1: Taxes"
        t.main_ideas = "PART 2: Retirement Accounts"
        t.criticism = "PART 3: Real-World Tie-In"
        t.suggested_reading = "Exit Ticket content"
        t.published = true
      end
    end

    it "renders the custom lesson plan layout" do
      # Assuming the route is /lesson_plan/:id
      # I'll check routes.rb to be sure, but based on context page="/lesson_plan/20"
      get "/lesson_plan/20"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Utah State Standards Alignment")
      expect(response.body).to include("PART 1")
      expect(response.body).to include("PART 2")
      expect(response.body).to include("PART 3")
      expect(response.body).to include("Exit Ticket")
    end

    it "styles markers correctly" do
      lesson_plan.update!(legacy: "Mini-Lesson: How to file taxes")
      get "/lesson_plan/20"
      expect(response.body).to include("Mini-Lesson")
      expect(response.body).to include("bg-[#f9a825]/10")
    end
  end
end
