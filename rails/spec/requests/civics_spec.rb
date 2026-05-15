require 'rails_helper'

RSpec.describe "Civics", type: :request do
  let!(:civic_topic) do 
    CivicTopic.create!(
      name: "Andrew Yang", 
      bio: "Andrew Yang emerged as a distinctive figure in the 2020 Democratic presidential campaign.",
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
end