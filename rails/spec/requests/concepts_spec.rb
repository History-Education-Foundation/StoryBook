require 'rails_helper'

RSpec.describe "Concepts", type: :request do
  let!(:concept) { Concept.create!(name: "Federalism", bio: "A system of government") }

  describe "GET /concepts" do
    it "returns a success response and lists concepts" do
      get concepts_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Federalism")
    end
  end

  describe "GET /concepts/:id" do
    it "returns a success response for a valid concept" do
      get concept_path(concept)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Federalism")
    end
  end
end
