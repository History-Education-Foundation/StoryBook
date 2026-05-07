require 'rails_helper'

RSpec.describe Author, type: :model do
  describe "associations" do
    it "has many posts" do
      author = Author.reflect_on_association(:posts)
      expect(author.macro).to eq(:has_many)
    end
  end

  describe "validations" do
    it "is valid with a name" do
      author = Author.new(name: "John Doe")
      expect(author).to be_valid
    end

    it "is invalid without a name" do
      author = Author.new(name: nil)
      expect(author).not_to be_valid
    end
  end
end
