class AddMainIdeasHeadingToScholars < ActiveRecord::Migration[7.2]
  def change
    add_column :scholars, :main_ideas_heading, :string
  end
end
