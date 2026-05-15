require 'rails_helper'

RSpec.describe CivicTopic, type: :model do
  describe 'validations' do
    it 'is valid with a name' do
      topic = CivicTopic.new(name: 'Test Topic')
      expect(topic).to be_valid
    end

    it 'is invalid without a name' do
      topic = CivicTopic.new(name: nil)
      expect(topic).not_to be_valid
      expect(topic.errors[:name]).to include("can't be blank")
    end
  end

  describe 'Andrew Yang content verification' do
    it 'has the correct contributions count for Andrew Yang' do
      yang = CivicTopic.create!(
        name: "Andrew Yang",
        contributions: "Fact 1\nFact 2\nFact 3\nFact 4\nFact 5"
      )
      expect(yang.contributions.split("\n").count).to eq(5)
    end
  end

  describe 'defaults' do
    it 'is not published by default' do
      topic = CivicTopic.new(name: 'Test Topic')
      expect(topic.published).to be false
    end
  end

  describe 'attachments' do
    it 'can have an attached image' do
      topic = CivicTopic.new(name: 'Test Topic')
      file_path = Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')
      
      # Ensure the fixture directory and file exist for the test
      unless File.exist?(file_path)
        FileUtils.mkdir_p(File.dirname(file_path))
        File.open(file_path, 'wb') { |f| f.write('dummy content') }
      end

      topic.image.attach(io: File.open(file_path), filename: 'test_image.png', content_type: 'image/png')
      expect(topic.image).to be_attached
    end
  end

  describe 'American Civics Renewal Act consolidation' do
    let(:topic) do
      CivicTopic.find_or_create_by!(name: "American Civics Renewal Act")
    end

    it 'has consolidated the narrative into the bio field' do
      topic.update!(
        bio: "As the United States approaches its 250th anniversary, civics education has experienced a surge of legislation and funding... Work Cited:",
        bio_heading: "American Civics Renewal Act",
        contributions: nil,
        main_ideas: nil,
        legacy: nil,
        criticism: nil
      )

      expect(topic.bio).to include("As the United States approaches its 250th anniversary")
      expect(topic.bio).to include("Work Cited:")
      expect(topic.bio_heading).to eq("American Civics Renewal Act")
    end

    it 'has cleared the fragmented metadata fields' do
      topic.update!(contributions: nil, main_ideas: nil, legacy: nil, criticism: nil)
      
      expect(topic.contributions).to be_nil
      expect(topic.main_ideas).to be_nil
      expect(topic.legacy).to be_nil
      expect(topic.criticism).to be_nil
    end
  end

  describe 'Context for CD1 in Utah consolidation' do
    let(:topic) do
      CivicTopic.find_or_create_by!(name: "Potential context for Utah’s 1st Congressional District (CD1) Race")
    end

    it 'has consolidated the narrative into the bio field' do
      topic.update!(
        bio: "As a tax-exempt non-profit, The History Education Foundation does not endorse political candidates... A functioning democracy requires evaluating both individual accountability and systemic influence.",
        bio_heading: "Context for CD1 in Utah",
        contributions: nil,
        main_ideas: nil,
        legacy: nil,
        criticism: nil
      )

      expect(topic.bio).to include("As a tax-exempt non-profit, The History Education Foundation does not endorse political candidates.")
      expect(topic.bio).to include("A functioning democracy requires evaluating both individual accountability and systemic influence.")
      expect(topic.bio_heading).to eq("Context for CD1 in Utah")
    end

    it 'has cleared the fragmented metadata fields' do
      topic.update!(contributions: nil, main_ideas: nil, legacy: nil, criticism: nil)
      
      expect(topic.contributions).to be_nil
      expect(topic.main_ideas).to be_nil
      expect(topic.legacy).to be_nil
      expect(topic.criticism).to be_nil
    end
  end
end
