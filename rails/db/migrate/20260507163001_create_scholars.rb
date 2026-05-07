class CreateScholars < ActiveRecord::Migration[7.2]
  def change
    create_table :scholars do |t|
      t.string :name
      t.text :bio

      t.timestamps
    end
  end
end
