class AddMoreHeadingsToScholars < ActiveRecord::Migration[7.2]
  def change
    add_column :scholars, :bio_heading, :string
    add_column :scholars, :contributions_heading, :string
  end
end
