FactoryBot.define do
  factory :comment do
    value {Faker::Name.name }
    association :user, factory: :user, email: Faker::Internet.email, password: "password123"
  end
end