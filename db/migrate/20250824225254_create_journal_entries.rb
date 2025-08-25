class CreateJournalEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :journal_entries do |t|
      t.string :title
      t.text :body
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
