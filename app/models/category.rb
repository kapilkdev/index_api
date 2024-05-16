class Category < ApplicationRecord
  has_many :articles, dependent: :destroy

  def self.ransackable_attributes(auth_object = nil)
    %w[id name ]
  end
end
