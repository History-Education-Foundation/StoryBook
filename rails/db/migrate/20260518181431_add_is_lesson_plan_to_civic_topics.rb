class AddIsLessonPlanToCivicTopics < ActiveRecord::Migration[7.2]
  def change
    unless column_exists?(:civic_topics, :is_lesson_plan)
      add_column :civic_topics, :is_lesson_plan, :boolean, default: false
    end
  end
end
