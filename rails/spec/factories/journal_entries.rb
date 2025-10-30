FactoryBot.define do
  factory :journal_entry do
    sequence(:title) { |n| "Journal Entry #{n}" }
    body { "This is a test journal entry" }
    association :user
    goal { nil }
  end
end
