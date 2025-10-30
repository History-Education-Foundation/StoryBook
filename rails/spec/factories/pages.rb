FactoryBot.define do
  factory :page do
    content { "This is page content" }
    association :chapter
    created_at { Time.current }
    updated_at { Time.current }
  end
end
