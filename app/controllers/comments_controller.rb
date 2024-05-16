class CommentsController < ApplicationController
  before_action :find_article
  skip_before_action :authorized, only: [:show]
  
  def create
    @comment = @article.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      return render json: {notice: "Comment was successfully created.",comment: CommentSerializer.new(@comment)}
    else
      return render json:{ error: "Comment not created"},status: :unprocessable_entity
    end
  end

  def show
    @comment = Comment.find_by(id: params[:id])
    if @comment 
      return render json: {notice: "Comment was successfully fetched.",comment: CommentSerializer.new(@comment)}
    else
      return render json:{ error: "Comment not found"},status: 404
    end

  end

  private
    def comment_params
      params.require(:comment).permit(:value)
    end

    def find_article 
      @article = Article.find_by(id: params[:article_id])
      return render json: {error: "Article not found"},status: 404 unless @article
    end
end
