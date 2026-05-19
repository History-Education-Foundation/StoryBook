class SplitSocialAndPersonalityTopic < ActiveRecord::Migration[7.2]
  def up
    CivicTopic.find_by(id: 27)&.destroy
  end

  def down
    # Hard to revert a delete if we don't know the exact data, but we can recreate it if needed.
    # However, this is a one-way split.
  end
end
