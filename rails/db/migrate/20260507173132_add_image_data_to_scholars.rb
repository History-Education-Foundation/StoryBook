class AddImageDataToScholars < ActiveRecord::Migration[7.2]
  def change
    add_column :scholars, :image_data, :text
  end
end
