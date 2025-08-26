class Goal < ApplicationRecord
  belongs_to :user
  has_many :journal_entries, dependent: :nullify
end
