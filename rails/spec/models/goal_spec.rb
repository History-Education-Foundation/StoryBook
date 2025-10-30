require 'rails_helper'

RSpec.describe Goal, type: :model do
  describe "associations" do
    it "belongs to a user" do
      user = create(:user)
      goal = create(:goal, user: user)
      expect(goal.user).to eq(user)
    end
  end

  describe "validations" do
    it "requires a user association" do
      goal = build(:goal, user: nil)
      expect(goal).not_to be_valid
    end
  end

  describe "goal creation" do
    it "creates a valid goal with required attributes" do
      user = create(:user)
      goal = create(:goal, user: user)
      expect(goal).to be_persisted
      expect(goal.user).to eq(user)
    end

    it "creates a goal with optional attributes" do
      user = create(:user)
      goal = create(:goal,
                   user: user,
                   title: "Learn Rails",
                   description: "Master Rails framework",
                   status: "In Progress",
                   target_date: Date.tomorrow)
      expect(goal.title).to eq("Learn Rails")
      expect(goal.description).to eq("Master Rails framework")
      expect(goal.status).to eq("In Progress")
      expect(goal.target_date).to eq(Date.tomorrow)
    end

    it "cannot create a goal without a user" do
      goal = build(:goal, user: nil)
      expect(goal).not_to be_valid
    end
  end

  describe "relationships" do
    it "associates with a user" do
      user = create(:user)
      goal = create(:goal, user: user)
      expect(goal.user).to eq(user)
    end

    it "can be deleted independently from user" do
      user = create(:user)
      goal = create(:goal, user: user)
      goal.destroy
      expect(Goal.find_by(id: goal.id)).to be_nil
      expect(User.find_by(id: user.id)).to eq(user)
    end
  end

  describe "timestamps" do
    it "has created_at timestamp" do
      goal = create(:goal)
      expect(goal.created_at).not_to be_nil
    end

    it "has updated_at timestamp" do
      goal = create(:goal)
      expect(goal.updated_at).not_to be_nil
      goal.update(title: "Updated Goal")
      expect(goal.updated_at).to be >= goal.created_at
    end
  end

  describe "date fields" do
    it "accepts nil target_date" do
      user = create(:user)
      goal = create(:goal, user: user, target_date: nil)
      expect(goal.target_date).to be_nil
    end

    it "accepts future dates" do
      user = create(:user)
      future_date = 1.year.from_now.to_date
      goal = create(:goal, user: user, target_date: future_date)
      expect(goal.target_date).to eq(future_date)
    end
  end

  describe "status field" do
    it "accepts various status values" do
      user = create(:user)
      statuses = ["Active", "Completed", "In Progress", "On Hold"]
      statuses.each do |status|
        goal = create(:goal, user: user, status: status)
        expect(goal.status).to eq(status)
      end
    end
  end
end
