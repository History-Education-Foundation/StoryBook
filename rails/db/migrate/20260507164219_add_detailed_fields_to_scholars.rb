class AddDetailedFieldsToScholars < ActiveRecord::Migration[7.2]
  def change
    add_column :scholars, :tagline, :string
    add_column :scholars, :contributions, :text
    add_column :scholars, :main_ideas, :text
    add_column :scholars, :legacy, :text
    add_column :scholars, :suggested_reading, :text
  end
end
