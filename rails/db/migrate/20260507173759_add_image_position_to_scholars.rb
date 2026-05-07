class AddImagePositionToScholars < ActiveRecord::Migration[7.2]
  def change
    add_column :scholars, :image_position, :string
  end
end
