class CommentSerializer
  include JSONAPI::Serializer
  attributes :value, :article_id
  
  attribute :user do |object|
    user = User.find_by(id: object.user_id)
    UserSerializer.new(user)
  end


end
