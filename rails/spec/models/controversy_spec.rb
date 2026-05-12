require 'rails_helper'

RSpec.describe Controversy, type: :model do
  describe 'validations' do
    it 'is valid with a name' do
      controversy = Controversy.new(name: 'Test Controversy')
      expect(controversy).to be_valid
    end

    it 'is invalid without a name' do
      controversy = Controversy.new(name: nil)
      expect(controversy).not_to be_valid
      expect(controversy.errors[:name]).to include("can't be blank")
    end
  end

  describe 'attachments' do
    it 'can have an attached image' do
      controversy = Controversy.new(name: 'Test Controversy')
      file_path = Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')
      
      # Ensure the fixture directory and file exist for the test
      unless File.exist?(file_path)
        FileUtils.mkdir_p(File.dirname(file_path))
        File.open(file_path, 'wb') { |f| f.write('dummy content') }
      end

      controversy.image.attach(io: File.open(file_path), filename: 'test_image.png', content_type: 'image/png')
      expect(controversy.image).to be_attached
    end
  end
end
