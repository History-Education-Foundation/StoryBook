require 'rails_helper'

RSpec.describe Concept, type: :model do
  describe 'validations' do
    it 'is valid with a name' do
      concept = Concept.new(name: 'Test Concept')
      expect(concept).to be_valid
    end

    it 'is invalid without a name' do
      concept = Concept.new(name: nil)
      expect(concept).not_to be_valid
      expect(concept.errors[:name]).to include("can't be blank")
    end
  end
end
