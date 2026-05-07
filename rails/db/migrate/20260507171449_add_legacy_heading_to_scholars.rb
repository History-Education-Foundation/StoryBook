class AddLegacyHeadingToScholars < ActiveRecord::Migration[7.2]
  def change
    add_column :scholars, :legacy_heading, :string
  end
end
