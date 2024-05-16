class Tag < ApplicationRecord
  has_many :taggings
  has_many :articles, through: :taggings
  before_validation :downcase_name
  validates :name, presence: true, uniqueness: true

  private

  def downcase_name
    self.name = name.downcase if name.present?
  end

end
