FactoryBot.define do
  factory :post do
    sequence(:title) { |n| "Post #{n}" }
    body { "This is a test post body" }
    association :user
  end
end
