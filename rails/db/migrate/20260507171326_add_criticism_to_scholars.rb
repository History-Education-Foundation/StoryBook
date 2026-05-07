class AddCriticismToScholars < ActiveRecord::Migration[7.2]
  def change
    add_column :scholars, :criticism, :text
    add_column :scholars, :criticism_heading, :string
  end
end
