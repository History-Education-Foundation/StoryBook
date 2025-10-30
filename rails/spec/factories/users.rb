FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "Password123!" }
    password_confirmation { "Password123!" }
    name { "Test User" }
    role { "staff" }
    admin { false }

    trait :admin_user do
      role { "admin" }
      admin { true }
    end

    trait :student do
      role { "student" }
    end

    trait :staff do
      role { "staff" }
    end
  end
end
