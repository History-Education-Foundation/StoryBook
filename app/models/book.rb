class Book < ApplicationRecord
  belongs_to :user
  has_many :chapters, dependent: :destroy
  has_many :saved_books, dependent: :destroy
  has_many :saved_by_users, through: :saved_books, source: :user

  STATUSES = ["Draft", "Published", "Archived"].freeze

  after_initialize do
    self.status ||= "Draft"
  end
end
