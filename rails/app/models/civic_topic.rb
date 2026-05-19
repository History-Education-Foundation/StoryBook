class CivicTopic < ApplicationRecord
  has_one_attached :image
  has_one_attached :handout_pdf

  validates :name, presence: true

  belongs_to :parent, class_name: "CivicTopic", optional: true
  has_many :sub_topics, class_name: "CivicTopic", foreign_key: "parent_id", dependent: :destroy

  scope :published, -> { where(published: true) }
  scope :by_subject, ->(subject) { where(subject: subject) }
  scope :grade_8, -> { where(grade_level: "8th Grade") }
  scope :us_history, -> { where(subject: "U.S. History") }

  def is_lesson_plan?
    is_lesson_plan || [12, 9, 40, 20, 19, 21, 17].include?(id) || subject == "Lesson Plan"
  end
end
