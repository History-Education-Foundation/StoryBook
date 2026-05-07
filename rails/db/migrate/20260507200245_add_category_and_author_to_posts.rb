class AddCategoryAndAuthorToPosts < ActiveRecord::Migration[7.2]
  def change
    add_reference :posts, :category, null: true, foreign_key: true
    add_reference :posts, :author, null: true, foreign_key: true
  end
end
