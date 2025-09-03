class CreatePages < ActiveRecord::Migration[7.2]
  def change
    create_table :pages do |t|
      t.string :content
      t.references :chapter, null: false, foreign_key: true

      t.timestamps
    end
  end
end
