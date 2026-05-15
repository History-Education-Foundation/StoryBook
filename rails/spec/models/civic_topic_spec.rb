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
end