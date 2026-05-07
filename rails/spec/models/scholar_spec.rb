require 'rails_helper'

RSpec.describe Scholar, type: :model do
  describe 'validations' do
    it 'is valid with a name' do
      scholar = Scholar.new(name: 'Test Scholar')
      expect(scholar).to be_valid
    end

    it 'is invalid without a name' do
      scholar = Scholar.new(name: nil)
      expect(scholar).not_to be_valid
      expect(scholar.errors[:name]).to include("can't be blank")
    end
  end
end
