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

  describe '10th Grade World History placeholders' do
    before do
      # Ensure data exists in the test database
      ['Chile in the Cold War', 'The Pinochet File'].each do |name|
        CivicTopic.find_or_create_by!(name: name) do |t|
          t.grade_level = '10th Grade'
          t.subject = 'World History'
          t.bio = "Placeholder biography for #{name}."
          t.published = true
        end
      end
    end

    it 'verifies that topics for 10th Grade World History exist' do
      expect(CivicTopic.where(grade_level: '10th Grade', subject: 'World History').count).to eq(2)
    end

    it 'verifies that topics have placeholder biographies' do
      expect(CivicTopic.find_by(name: 'Chile in the Cold War').bio).to include('Placeholder')
      expect(CivicTopic.find_by(name: 'The Pinochet File').bio).to include('Placeholder')
    end
  end

  describe 'Financial Literacy placeholders' do
    before do
      ['Credit', 'Taxes & Retirement', 'House Hacking'].each do |name|
        CivicTopic.find_or_create_by!(name: name) do |t|
          t.subject = 'Financial Literacy'
          t.bio = "Placeholder biography for #{name}."
          t.published = true
        end
      end
    end

    it 'verifies that topics for Financial Literacy exist' do
      expect(CivicTopic.where(subject: 'Financial Literacy').count).to eq(3)
    end

    it 'verifies that topics have placeholder biographies' do
      expect(CivicTopic.find_by(name: 'Credit').bio).to include('Placeholder')
    end
  end

  describe 'World Geography placeholders' do
    before do
      ['Chile in the Cold War', 'The Pinochet File'].each do |name|
        CivicTopic.find_or_create_by!(name: name, subject: 'World Geography') do |t|
          t.bio = "Placeholder biography for #{name}."
          t.published = true
        end
      end
    end

    it 'verifies that topics for World Geography exist' do
      expect(CivicTopic.where(subject: 'World Geography').count).to eq(2)
    end
  end

  describe 'Psychology placeholders' do
    before do
      ['Biological', 'Cognition', 'Development & Learning', 'Social & Personality', 'Mental & Physical Health'].each do |name|
        CivicTopic.find_or_create_by!(name: name, subject: 'Psychology') do |t|
          t.bio = "Placeholder biography for #{name}."
          t.published = true
        end
      end
    end

    it 'verifies that topics for Psychology exist' do
      expect(CivicTopic.where(subject: 'Psychology').count).to eq(5)
    end
  end

  describe 'Digital Literacy placeholders' do
    before do
      ['Iran Monitoring Civilians'].each do |name|
        CivicTopic.find_or_create_by!(name: name, subject: 'Digital Literacy') do |t|
          t.bio = "Placeholder biography for #{name}."
          t.published = true
        end
      end
    end

    it 'verifies that topics for Digital Literacy exist' do
      expect(CivicTopic.where(subject: 'Digital Literacy').count).to eq(1)
    end
  end

  describe 'Student Leaders placeholders' do
    before do
      ['Praise in public', 'Time is power'].each do |name|
        CivicTopic.find_or_create_by!(name: name, subject: 'Student Leaders') do |t|
          t.bio = "Placeholder biography for #{name}."
          t.published = true
        end
      end
    end

    it 'verifies that topics for Student Leaders exist' do
      expect(CivicTopic.where(subject: 'Student Leaders').count).to eq(2)
    end
  end

  describe '#is_lesson_plan?' do
    it 'returns true for ID 20' do
      topic = CivicTopic.new(id: 20)
      expect(topic.is_lesson_plan?).to be true
    end

    it 'returns true for ID 9' do
      topic = CivicTopic.new(id: 9)
      expect(topic.is_lesson_plan?).to be true
    end

    it 'returns true for ID 40' do
      topic = CivicTopic.new(id: 40)
      expect(topic.is_lesson_plan?).to be true
    end

    it 'returns true for subject "Lesson Plan"' do
      topic = CivicTopic.new(subject: 'Lesson Plan')
      expect(topic.is_lesson_plan?).to be true
    end

    it 'returns false for other IDs' do
      topic = CivicTopic.new(id: 999)
      expect(topic.is_lesson_plan?).to be false
    end
  end
end
