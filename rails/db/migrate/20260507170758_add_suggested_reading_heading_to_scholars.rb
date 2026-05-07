class AddSuggestedReadingHeadingToScholars < ActiveRecord::Migration[7.2]
  def change
    add_column :scholars, :suggested_reading_heading, :string
  end
end
