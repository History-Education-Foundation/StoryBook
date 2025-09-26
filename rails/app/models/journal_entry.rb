class JournalEntry < ApplicationRecord
  belongs_to :user
  belongs_to :goal, optional: true
end
