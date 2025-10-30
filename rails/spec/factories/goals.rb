FactoryBot.define do
  factory :goal do
    sequence(:title) { |n| "Goal #{n}" }
    description { "This is a test goal" }
    status { "Active" }
    target_date { 3.months.from_now.to_date }
    association :user
  end
end
