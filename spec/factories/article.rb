FactoryBot.define do
  factory :article do
    title { "Sample Article" }
    description { "This is a sample article description." }
    category_id { create(:category).id } # Assuming you have a Category factory defined
    status { "published" }
    association :user, factory: :user, email: Faker::Internet.email, password: "password123"
  end
end
