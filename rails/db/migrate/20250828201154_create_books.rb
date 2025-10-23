class CreateBooks < ActiveRecord::Migration[7.2]
  def change
    create_table :books do |t|
      t.string :title
      t.text :learning_outcome
      t.string :reading_level
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
