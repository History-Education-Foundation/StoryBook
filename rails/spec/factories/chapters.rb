FactoryBot.define do
  factory :chapter do
    sequence(:title) { |n| "Chapter #{n}" }
    description { "This is a test chapter" }
    association :book
  end
end
