require 'faker'

# create admin

AdminUser.find_or_create_by(email: 'admin@example.com') do |admin_user|
  admin_user.password = 'password'
  admin_user.password_confirmation = 'password'
end

# Create categories
3.times do
  Category.create!(
    name: Faker::Book.genre
  )
end

# Create users
10_000.times do
  User.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    email: Faker::Internet.unique.email,
    password_digest: Faker::Internet.password(min_length: 8),
    created_at: Faker::Time.between(from: DateTime.now - 1.year, to: DateTime.now),
    updated_at: Faker::Time.between(from: DateTime.now - 1.year, to: DateTime.now),
    ban: Faker::Boolean.boolean(true_ratio: 0.1),
    reset_password_token: nil,
    reset_password_sent_at: nil
  )
end

# Create articles
User.all.each do |user|
  2.times do
    Article.create!(
      title: Faker::Book.title,
      description: Faker::Lorem.paragraph,
      category_id: Category.pluck(:id).sample,
      user_id: user.id,
      status: ['draft', 'published', 'archived'].sample,
      discarded_at: nil,
      is_discarded: false,
      created_at: Faker::Time.between(from: user.created_at, to: DateTime.now),
      updated_at: Faker::Time.between(from: user.created_at, to: DateTime.now)
    )
  end
end
