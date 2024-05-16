class ArticleSerializer < ActiveModel::Serializer
  include FastJsonapi::ObjectSerializer
  attributes :id,:title,:description,:status

  attribute :comments, if: Proc.new{|object| object.comments.present?} do |object|
    comments = object.comments.paginate(:page => 1, :per_page => 25)
    CommentSerializer.new(comments).serializable_hash
  end

  attribute :tags, if: Proc.new{|object| object.tags.present?} do |object|
    object.tags
  end
end
