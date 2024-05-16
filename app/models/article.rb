class Article < ApplicationRecord
  include Discard::Model
  has_paper_trail 
  enum :status, { published: "published",hidden: "hidden" }
  has_one_attached :cover
  belongs_to :user
  belongs_to :category
  has_many :comments, dependent: :destroy
  has_many :taggings
  has_many :tags, through: :taggings

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "title","status","is_discarded"]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[category  user ]
  end


  def rollback_to(version_number)
    versions = self.versions.where(event: "update").order(created_at: :desc).limit(5)
    version_to_revert = versions.find_by(id: version_number)
    return unless version_to_revert
    reverted_attributes = self.paper_trail.version_at(version_to_revert.created_at).attributes
    self.update(reverted_attributes)
  end

  def build_tagging_with_tag(tag_params)
    tag = Tag.find_or_initialize_by(name: tag_params[:name].downcase)
    tag.attributes = tag_params unless tag
    taggings.build(tag: tag)
  end

  
end

