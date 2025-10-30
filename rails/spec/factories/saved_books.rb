FactoryBot.define do
  factory :saved_book do
    association :user
    association :book
    created_at { Time.current }
    updated_at { Time.current }
  end
end
