
FactoryBot.define do
  factory :admin_user do
    email { Faker::Internet.email }
    password { 'password123' }
    
  end
end