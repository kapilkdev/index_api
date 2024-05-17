require 'faker'
require 'bcrypt'

Faker::UniqueGenerator.clear 

# Create admin
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

num_users = 1000
batch_size = 500
generated_emails = []

# Create users in batches
(num_users / batch_size).times do
  users_batch = []
  batch_size.times do
    first_name = Faker::Name.first_name
    last_name = Faker::Name.last_name
    email = Faker::Internet.unique.email

    while generated_emails.include?(email)
      email = Faker::Internet.unique.email
    end

    generated_emails << email

    users_batch << {
      first_name: first_name,
      last_name: last_name,
      email: email,
      password_digest: BCrypt::Password.create('password'),
      created_at: Time.now,
      updated_at: Time.now
    }
  end
  User.insert_all(users_batch)
end

# Create articles for each user in batches
User.find_in_batches(batch_size: batch_size) do |users|
  articles_batch = []
  users.each do |user|
    2.times do
      articles_batch << {
        title: Faker::Book.title,
        description: Faker::Lorem.paragraph,
        category_id: Category.pluck(:id).sample,
        user_id: user.id,
        status: ['draft', 'published', 'archived'].sample,
        discarded_at: nil,
        is_discarded: false,
        created_at: Faker::Time.between(from: user.created_at, to: DateTime.now),
        updated_at: Faker::Time.between(from: user.created_at, to: DateTime.now)
      }
    end
  end
  
  Article.insert_all(articles_batch)
end