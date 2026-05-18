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
      expect(response.body).not_to include("first-letter:text-8xl")
      expect(response.body).not_to include("first-letter:float-left")
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