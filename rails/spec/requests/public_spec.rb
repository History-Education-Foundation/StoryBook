require 'rails_helper'

RSpec.describe "Public", type: :request do
  describe "GET /" do
    it "renders the mission section with logo and support button" do
      get root_path
      expect(response).to have_http_status(:success)
      
      # Check for mission section
      expect(response.body).to include('id="mission"')
      
      # Check for logo in mission section
      # Note: asset_path might return different things in test vs dev, but we expect the img tag
      expect(response.body).to include('alt="Foundation Logo"')
      
      # Check for "Support Us" button
      expect(response.body).to include('Support Us')
      expect(response.body).to include('href="' + new_user_registration_path + '"')
      expect(response.body).to include('bg-[#f9a825]') # Check for the specific brand color
    end
  end
end
