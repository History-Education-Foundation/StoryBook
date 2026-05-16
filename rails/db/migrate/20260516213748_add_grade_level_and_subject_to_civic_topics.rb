class AddGradeLevelAndSubjectToCivicTopics < ActiveRecord::Migration[7.2]
  def change
    add_column :civic_topics, :grade_level, :string
    add_column :civic_topics, :subject, :string
  end
end
