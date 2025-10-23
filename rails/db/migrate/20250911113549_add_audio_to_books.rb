class AddAudioToBooks < ActiveRecord::Migration[7.2]
  def change
    add_column :books, :audio, :string
  end
end
