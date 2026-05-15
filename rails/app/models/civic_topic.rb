class CivicTopic < ApplicationRecord
  has_one_attached :image
  has_one_attached :handout_pdf
  validates :name, presence: true
end
