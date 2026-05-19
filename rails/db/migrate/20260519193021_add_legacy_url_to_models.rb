class AddLegacyUrlToModels < ActiveRecord::Migration[7.2]
  def change
    tables = [:civic_topics, :controversies, :scholars, :concepts, :posts, :historical_figures]

    tables.each do |table_name|
      add_column table_name, :legacy_url, :string
      add_index table_name, :legacy_url, unique: true
    end
  end
end
