require 'rails_helper'

RSpec.describe JournalEntry, type: :model do
  describe "associations" do
    it "belongs to a user" do
      user = create(:user)
      entry = create(:journal_entry, user: user)
      expect(entry.user).to eq(user)
    end
  end

  describe "validations" do
    it "requires a user association" do
      entry = build(:journal_entry, user: nil)
      expect(entry).not_to be_valid
    end
  end

  describe "journal entry creation" do
    it "creates a valid journal entry with required attributes" do
      user = create(:user)
      entry = create(:journal_entry, user: user)
      expect(entry).to be_persisted
      expect(entry.user).to eq(user)
    end

    it "creates a journal entry with optional attributes" do
      user = create(:user)
      entry = create(:journal_entry,
                    user: user,
                    title: "Today's Reflection",
                    body: "I learned something new today")
      expect(entry.title).to eq("Today's Reflection")
      expect(entry.body).to eq("I learned something new today")
    end

    it "can associate with a goal" do
      user = create(:user)
      goal = create(:goal, user: user)
      entry = create(:journal_entry, user: user, goal: goal)
      expect(entry.goal).to eq(goal)
    end

    it "cannot create a journal entry without a user" do
      entry = build(:journal_entry, user: nil)
      expect(entry).not_to be_valid
    end
  end

  describe "relationships" do
    it "associates with a user" do
      user = create(:user)
      entry = create(:journal_entry, user: user)
      expect(entry.user).to eq(user)
    end

    it "optionally associates with a goal" do
      user = create(:user)
      goal = create(:goal, user: user)
      entry = create(:journal_entry, user: user, goal: goal)
      expect(entry.goal).to eq(goal)
    end

    it "can exist without a goal" do
      user = create(:user)
      entry = create(:journal_entry, user: user, goal: nil)
      expect(entry.goal).to be_nil
    end

    it "can be deleted independently from user" do
      user = create(:user)
      entry = create(:journal_entry, user: user)
      entry.destroy
      expect(JournalEntry.find_by(id: entry.id)).to be_nil
      expect(User.find_by(id: user.id)).to eq(user)
    end
  end

  describe "timestamps" do
    it "has created_at timestamp" do
      entry = create(:journal_entry)
      expect(entry.created_at).not_to be_nil
    end

    it "has updated_at timestamp" do
      entry = create(:journal_entry)
      expect(entry.updated_at).not_to be_nil
      entry.update(title: "Updated Title")
      expect(entry.updated_at).to be >= entry.created_at
    end
  end

  describe "content fields" do
    it "accepts nil title" do
      user = create(:user)
      entry = create(:journal_entry, user: user, title: nil)
      expect(entry.title).to be_nil
    end

    it "accepts nil body" do
      user = create(:user)
      entry = create(:journal_entry, user: user, body: nil)
      expect(entry.body).to be_nil
    end

    it "accepts long body content" do
      user = create(:user)
      long_body = "A" * 10000
      entry = create(:journal_entry, user: user, body: long_body)
      expect(entry.body).to eq(long_body)
    end
  end
end
