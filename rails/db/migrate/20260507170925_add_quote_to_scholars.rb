class AddQuoteToScholars < ActiveRecord::Migration[7.2]
  def change
    add_column :scholars, :quote, :text
    add_column :scholars, :quote_author, :string
  end
end
