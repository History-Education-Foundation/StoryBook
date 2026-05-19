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

  describe "GET /lesson_plans/:id (Deindividuation)" do
    let!(:topic) do
      CivicTopic.find_by(name: "Deindividuation") || CivicTopic.create!(
        name: "Deindividuation",
        bio: "OBJECTIVES\n* Define the concept\nHook: STARTER QUESTIONS\nDisplay a blank version of Canva post",
        legacy_heading: "Phase 01: Concept Introduction & Origins",
        legacy: "Mini-Lesson: CONCEPT INTRODUCTION\nTerm: APA Dictionary of Psychology\nMini-Lesson: ORIGINS OF DEINDIVIDUATION",
        main_ideas_heading: "Phase 02: Causes & Symptoms",
        main_ideas: "CAUSES + SYMPTOMS OF DEINDIVIDUATION",
        criticism_heading: "Phase 03: Main Activity",
        criticism: "Activity: ACTIVITY #1: MASKED DECISION-MAKING ACTIVITY",
        suggested_reading_heading: "Final Reflection & Application",
        suggested_reading: "Discussion: HISTORY & REAL-WORLD CONNECTION\nDiscussion: FINAL REFLECTION",
        is_lesson_plan: true,
        published: true
      )
    end

    it "loads the Deindividuation lesson plan with high-fidelity content" do
      get lesson_plan_path(topic)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Deindividuation")
      expect(response.body).to include("STARTER QUESTIONS")
      expect(response.body).to include("CONCEPT INTRODUCTION")
      expect(response.body).to include("MASKED DECISION-MAKING ACTIVITY")
      expect(response.body).to include("FINAL REFLECTION")
      expect(response.body).not_to include("Placeholder")
    end
  end

  describe "GET /lesson_plans/:id (Social Influence)" do
    let!(:topic) do
      CivicTopic.find_by(name: "Social Influence") || CivicTopic.create!(
        name: "Social Influence",
        bio: "OBJECTIVES\nHook: INTRODUCTION ACTIVITY\nOption 1: Groupthink Experiment\nImage: Groupthink.png",
        legacy_heading: "Initial Discussion",
        legacy: "Discussion: Have students write down or ponder their answers",
        main_ideas_heading: "Main Lesson: Concepts & Vocab",
        main_ideas: "Video: Social Influence\nMini-Lesson: VOCABULARY\nTerm: Social Influence: “the process by which individuals adapt”",
        criticism_heading: "Deep Dive: Historical Experiments",
        criticism: "Activity: DEEP DIVE\n* Solomon Asch Line Experiment\n* Stanley Milgram Obedience Experiment",
        suggested_reading_heading: "Final Reflection & Readings",
        suggested_reading: "Discussion: BOOK CHAPTERS\nDiscussion: FINAL DISCUSSION",
        is_lesson_plan: true,
        published: true
      )
    end

    it "loads the Social Influence lesson plan with high-fidelity content" do
      get lesson_plan_path(topic)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Social Influence")
      expect(response.body).to include("INTRODUCTION ACTIVITY")
      expect(response.body).to include("Groupthink Experiment")
      expect(response.body).to include("Solomon Asch Line Experiment")
      expect(response.body).to include("Stanley Milgram Obedience Experiment")
      expect(response.body).to include("BOOK CHAPTERS")
      expect(response.body).not_to include("Placeholder")
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
