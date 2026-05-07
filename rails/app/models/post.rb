class Post < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true
  belongs_to :author, optional: true
end
