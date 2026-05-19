class AddParentIdToCivicTopics < ActiveRecord::Migration[7.2]
  def change
    add_column :civic_topics, :parent_id, :integer
    add_index :civic_topics, :parent_id
  end
end
