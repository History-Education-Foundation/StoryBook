require 'rails_helper'

RSpec.describe Category, type: :model do
  describe "associations" do
    it "has many posts" do
      category = Category.reflect_on_association(:posts)
      expect(category.macro).to eq(:has_many)
    end
  end

  describe "validations" do
    it "is valid with a name" do
      category = Category.new(name: "Tech")
      expect(category).to be_valid
    end

    it "is invalid without a name" do
      category = Category.new(name: nil)
      expect(category).not_to be_valid
    end
  end
end
