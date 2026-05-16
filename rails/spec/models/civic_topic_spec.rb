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
end
