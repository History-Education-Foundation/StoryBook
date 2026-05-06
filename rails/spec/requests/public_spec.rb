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

    it "renders the Who We Serve section with updated content and buttons" do
      get root_path
      expect(response.body).to include('Who We Serve')
      expect(response.body).to include('adaptable across diverse educational and civic contexts')
      expect(response.body).to include('Learn More')
      expect(response.body).to include('Get in touch')
      expect(response.body).to include('1000564435-2048x1365.jpg')
    end
  end
end
