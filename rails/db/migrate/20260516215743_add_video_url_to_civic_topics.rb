class AddVideoUrlToCivicTopics < ActiveRecord::Migration[7.2]
  def change
    add_column :civic_topics, :video_url, :string
  end
end
