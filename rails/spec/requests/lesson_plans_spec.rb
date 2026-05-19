require 'rails_helper'

RSpec.describe "LessonPlans", type: :request do
  describe "GET /lesson_plans/:id" do
    let!(:topic) do
      CivicTopic.find_by(id: 29) || CivicTopic.create!(
        id: 29,
        name: "Iran Monitoring Civilians",
        bio: "Explain (in simple terms) section content.",
        legacy_heading: "Mini-Lecture",
        legacy: "Mini-Lesson: Surveillance Systems as Networks (10 minutes)",
        main_ideas_heading: "Group Activity",
        main_ideas: "Activity: “Match the Hardware to the Function” (15 minutes)\n\nHardware | Function",
        criticism_heading: "Case Study",
        criticism: "Iran’s Monitoring Tools",
        suggested_reading: "Discussion: Ethical Questions (8 minutes)",
        is_lesson_plan: true,
        published: true
      )
    end

    it "loads the lesson plan layout for ID 29" do
      get lesson_plan_path(topic)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Iran Monitoring Civilians")
      expect(response.body).to include("Phase 01")
      expect(response.body).to include("Mini-Lesson")
      expect(response.body).not_to include("Placeholder")
    end

    it "renders the hardware matching table" do
      get lesson_plan_path(topic)
      expect(response.body).to include("<table")
      expect(response.body).to include("Hardware")
      expect(response.body).to include("Function")
    end
  end

  describe "GET /lesson_plans/:id (Chile in the Cold War)" do
    let!(:topic) do
      CivicTopic.find_by(id: 22) || CivicTopic.create!(
        id: 22,
        name: "Chile in the Cold War",
        bio: "Essential Question: How do power, perspective, and political interests shape the way history is told?\n\nPhase 01: Foundations\nPhase 02: Narrative Analysis\nPhase 03: Constructing Evidence\nExit Ticket",
        video_url: "https://www.youtube.com/embed/sF5kczRhW9E",
        is_lesson_plan: true,
        published: true
      )
    end

    it "loads the Chile in the Cold War lesson plan with correct content" do
      get lesson_plan_path(topic)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Chile in the Cold War")
      expect(response.body).to include("Essential Question: How do power, perspective, and political interests shape the way history is told?")
      expect(response.body).to include("Phase 01: Foundations")
      expect(response.body).to include("Phase 02: Narrative Analysis")
      expect(response.body).to include("Phase 03: Constructing Evidence")
      expect(response.body).to include("Exit Ticket")
    end

    it "renders the YouTube videos" do
      get lesson_plan_path(topic)
      expect(response.body).to include("https://www.youtube.com/embed/sF5kczRhW9E")
    end
  end

  describe "GET /lesson_plans" do
    let!(:topic) do
      CivicTopic.find_by(id: 29) || CivicTopic.create!(
        id: 29,
        name: "Iran Monitoring Civilians",
        bio: "Explain (in simple terms) section content.",
        is_lesson_plan: true,
        published: true
      )
    end

    it "shows Iran Monitoring as active and not marked Soon" do
      get "/lesson_plans"
      expect(response.body).to include("Iran Monitoring Civilians")
      expect(response.body).not_to include("Soon")
    end
  end
end
