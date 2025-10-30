FactoryBot.define do
  factory :book do
    sequence(:title) { |n| "Test Book #{n}" }
    learning_outcome { "Learn something new" }
    reading_level { "5th grade" }
    status { "Draft" }
    association :user

    trait :published do
      status { "Published" }
    end

    trait :archived do
      status { "Archived" }
    end
  end
end
