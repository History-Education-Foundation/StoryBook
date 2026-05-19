class Post < ApplicationRecord
  has_rich_text :body
  attr_accessor :new_category_name, :new_author_name

  belongs_to :user
  belongs_to :category, optional: true
  belongs_to :author, optional: true

  enum :status, { draft: 0, published: 1, archived: 2 }

  after_update_commit -> { broadcast_replace_to "posts" }
  after_destroy_commit -> { broadcast_remove_to "posts" }

  before_validation :handle_inline_creations

  validates :title, presence: true
  validates :body, presence: true
  validates :status, presence: true

  scope :visible_to_guest, -> { published }

  private

  def handle_inline_creations
    if new_category_name.present?
      self.category = Category.find_or_create_by!(name: new_category_name)
    end

    if new_author_name.present?
      self.author = Author.find_or_create_by!(name: new_author_name)
    end
  end
end
