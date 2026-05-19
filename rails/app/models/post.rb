class Post < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true
  belongs_to :author, optional: true

  validates :title, presence: true
  validates :body, presence: true
end
