class AddPublishedToConcepts < ActiveRecord::Migration[7.2]
  def change
    add_column :concepts, :published, :boolean, default: false
  end
end
