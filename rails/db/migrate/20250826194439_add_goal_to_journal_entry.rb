class AddGoalToJournalEntry < ActiveRecord::Migration[7.2]
  def change
    add_column :journal_entries, :goal_id, :integer
    add_index :journal_entries, :goal_id
  end
end
