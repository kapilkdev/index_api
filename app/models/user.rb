class User < ApplicationRecord
  has_secure_password
  has_many :articles, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_one_attached :avatar
  validates :email, uniqueness: true

  def self.ransackable_attributes(auth_object = nil)
    %w[id first_name last_name email ban ]
  end

  def send_password_reset
    self.reset_password_token = generate_base64_token
    self.reset_password_sent_at = Time.zone.now
    save!
  end

   
  def password_token_valid?
    (self.reset_password_sent_at + 4.hours) > Time.now.utc
  end
   
  def reset_password!(password)
    self.reset_password_token = nil
    self.password = password
    save!
  end
   
  private

  def generate_base64_token
    SecureRandom.hex(10)
  end

end
