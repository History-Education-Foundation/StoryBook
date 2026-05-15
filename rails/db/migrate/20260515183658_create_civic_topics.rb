class CreateCivicTopics < ActiveRecord::Migration[7.2]
  def change
    create_table :civic_topics do |t|
      t.string :name
      t.text :bio
      t.string :tagline
      t.text :contributions
      t.text :main_ideas
      t.text :legacy
      t.text :suggested_reading
      t.string :main_ideas_heading
      t.string :bio_heading
      t.string :contributions_heading
      t.text :publications
      t.string :publications_heading
      t.string :suggested_reading_heading
      t.text :quote
      t.string :quote_author
      t.text :criticism
      t.string :criticism_heading
      t.string :legacy_heading
      t.string :image_filename
      t.text :image_data
      t.string :image_position
      t.boolean :published, default: false

      t.timestamps
    end
  end
end
