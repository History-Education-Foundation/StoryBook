class AddAudioFileToBooks < ActiveRecord::Migration[7.2]
  def change
    # Use ActiveStorage for attachments, so no new DB column needed!
    # add_column :books, :audio_file, :string unless column_exists?(:books, :audio_file)
    # NOOP migration. Attachment is managed via ActiveStorage.
  end
end
