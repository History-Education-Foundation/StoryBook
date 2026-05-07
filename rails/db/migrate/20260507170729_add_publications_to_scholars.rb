class AddPublicationsToScholars < ActiveRecord::Migration[7.2]
  def change
    add_column :scholars, :publications, :text
    add_column :scholars, :publications_heading, :string
  end
end
