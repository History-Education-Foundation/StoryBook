class CivicTopic < ApplicationRecord
  has_one_attached :image
  has_one_attached :handout_pdf

  validates :name, presence: true

  scope :published, -> { where(published: true) }
  scope :by_subject, ->(subject) { where(subject: subject) }
  scope :grade_8, -> { where(grade_level: "8th Grade") }
  scope :us_history, -> { where(subject: "U.S. History") }
end
