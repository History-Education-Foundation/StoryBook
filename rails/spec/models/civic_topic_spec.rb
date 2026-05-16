require 'rails_helper'

RSpec.describe CivicTopic, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'scopes' do
    let!(:grade_8_us_history) { CivicTopic.create!(name: 'Grade 8 US History', grade_level: '8th Grade', subject: 'U.S. History') }
    let!(:high_school_gov) { CivicTopic.create!(name: 'HS Gov', grade_level: 'High School', subject: 'U.S Government') }

    it 'filters by grade 8' do
      expect(CivicTopic.grade_8).to include(grade_8_us_history)
      expect(CivicTopic.grade_8).not_to include(high_school_gov)
    end

    it 'filters by us history' do
      expect(CivicTopic.us_history).to include(grade_8_us_history)
      expect(CivicTopic.us_history).not_to include(high_school_gov)
    end
  end

  describe 'Separation of Powers (ID 11) content' do
    before do
      CivicTopic.find_or_create_by!(id: 11) do |t|
        t.name = "Separation of Powers"
        t.tagline = "(8th-grade reading level)\n\nHow the U.S. Government Prevents Any One Group From Becoming Too Powerful"
        t.bio = "The Founders..."
        t.main_ideas = "Step 1: Congress passes a law (Legislative).\nStep 2: The President vetoes it..."
        t.criticism = "Members of Congress may hesitate to challenge a President of their own party to avoid political backlash."
        t.published = true
      end
    end

    let(:topic) { CivicTopic.find_by(id: 11) }

    it 'contains specific keywords from the new content' do
      expect(topic.criticism).to include("political backlash")
      expect(topic.main_ideas).to include("vetoes it")
      expect(topic.tagline).to include("8th-grade reading level")
    end
  end
end
