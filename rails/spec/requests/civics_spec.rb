require 'rails_helper'

RSpec.describe "Civics", type: :request do
  let!(:civic_topic) do 
    CivicTopic.create!(
      name: "Andrew Yang", 
      bio: "Andrew Yang emerged as a distinctive figure in the 2020 Democratic presidential campaign. His innovative ideas and bold strategies aimed to reshape American politics and address the challenges of modern society.",
      bio_heading: "2020 Presidential Campaign",
      contributions: "Founded Venture for America in 2011\nRaised over $40 million in campaign contributions\nProposed Universal Basic Income of $1,000/month\nQualified for 7 Democratic debates\nSuspended campaign February 11, 2020",
      contributions_heading: "Key Facts",
      publications: "The War on Normal People",
      publications_heading: "Featured Book",
      published: true
    ) 
  end

  describe "GET /civics/:id" do
    it "returns a success response and shows campaign content" do
      get civic_path(civic_topic)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("2020 Presidential Campaign")
      expect(response.body).to include("Key Facts")
      expect(response.body).to include("The War on Normal People")
      expect(response.body).to include("Universal Basic Income")
    end

    it "does not contain dropcap classes" do
      get civic_path(civic_topic)
      expect(response.body).to include("first-letter:text-8xl")
      expect(response.body).to include("first-letter:float-left")
    end
  end

  describe "New Deal (ID 34) page" do
    before do
      CivicTopic.find_or_create_by!(id: 34) do |t|
        t.name = "New Deal"
        t.bio_heading = "Grant Larsen"
        t.bio = "Stone and Kuzinack combine a lot of New Deal procedures and policies..."
        t.published = true
      end
    end

    it "renders the Grant Larsen heading and dropcap" do
      get "/civics/34"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Grant Larsen")
      expect(response.body).to include("Stone and Kuzinack combine")
      expect(response.body).to include("first-letter:text-8xl")
    end
  end

  describe "U.S. Intervention abroad (ID 35) page" do
    before do
      CivicTopic.find_or_create_by!(id: 35) do |t|
        t.name = "U.S. Intervention abroad"
        t.bio_heading = "Grant Larsen"
        t.bio = "U.S. Intervention in other countries has happened... Work Cited: Posobiec, Jack"
        t.published = true
      end
    end

    it "renders the Grant Larsen heading, dropcap, and citations" do
      get "/civics/35"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Grant Larsen")
      expect(response.body).to include("U.S. Intervention in other countries")
      expect(response.body).to include("first-letter:text-8xl")
      expect(response.body).to include("Work Cited")
    end
  end

  describe "American Civics Renewal Act (ID 39) page" do
    before do
      CivicTopic.find_or_create_by!(id: 39) do |t|
        t.name = "American Civics Renewal Act"
        t.bio_heading = "Grant Larsen"
        t.bio = "As the United States approaches its 250th anniversary... Work Cited: American Civics Renewal Act"
        t.published = true
      end
    end

    it "renders the Grant Larsen heading, dropcap, and citations" do
      get "/civics/39"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Grant Larsen")
      expect(response.body).to include("As the United States approaches its 250th anniversary")
      expect(response.body).to include("first-letter:text-8xl")
      expect(response.body).to include("Work Cited")
    end
  end

  describe "Utah CD1 Context (ID 41) page" do
    before do
      CivicTopic.find_or_create_by!(id: 41) do |t|
        t.name = "Potential context for Utah’s 1st Congressional District (CD1) Race"
        t.bio_heading = "Context for CD1 in Utah"
        t.bio = "As a tax-exempt non-profit... power resists disruption."
        t.published = true
      end
    end

    it "renders the context heading and dropcap" do
      get "/civics/41"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Context for CD1 in Utah")
      expect(response.body).to include("As a tax-exempt non-profit")
      expect(response.body).to include("first-letter:text-8xl")
    end
  end

  describe "Separation of Powers (ID 11) page" do
    before do
      # Ensure record 11 exists in the test database with the correct content
      CivicTopic.find_or_create_by!(id: 11) do |t|
        t.name = "Separation of Powers"
        t.tagline = "(8th-grade reading level)\n\nHow the U.S. Government Prevents Any One Group From Becoming Too Powerful"
        t.bio = "The Founders..."
        t.criticism_heading = "Where Politics Complicate the System"
        t.published = true
      end
    end

    it "renders the new heading and tagline" do
      get "/civics/11"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Separation of Powers")
      expect(response.body).to include("8th-grade reading level")
      expect(response.body).to include("Where Politics Complicate the System")
    end
  end
end