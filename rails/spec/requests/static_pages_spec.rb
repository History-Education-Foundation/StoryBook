require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  describe "GET /contact" do
    it "returns http success" do
      get contact_path
      expect(response).to have_http_status(:success)
    end

    it "renders the contact template" do
      get contact_path
      expect(response).to render_template(:contact)
    end

    it "contains the contact header" do
      get contact_path
      expect(response.body).to include("Contact")
    end

    it "contains the FAQ section" do
      get contact_path
      expect(response.body).to include("Questions? We&#39;re here to help!")
      expect(response.body).to include("What areas do you service?")
    end

    it "contains the map iframe" do
      get contact_path
      expect(response.body).to include("iframe")
      expect(response.body).to include("San Francisco Centre")
    end
  end
end
