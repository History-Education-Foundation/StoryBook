require 'rails_helper'

RSpec.describe "Scholars", type: :request do
  describe "GET /scholars" do
    before do
      Scholar.create!(name: "Charles A. Beard")
      Scholar.create!(name: "Howard Zinn")
    end

    it "returns a 200 OK status" do
      get "/scholars"
      expect(response).to have_http_status(:ok)
    end

    it "includes the names of some of the scholars" do
      get "/scholars"
      expect(response.body).to include("Charles A. Beard")
      expect(response.body).to include("Howard Zinn")
    end
  end
end
