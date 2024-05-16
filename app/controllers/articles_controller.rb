class ArticlesController < ApplicationController
  include Rails.application.routes.url_helpers
  before_action :find_article, only: [:show,:destroy,:update, :edit, :destroy, :revert_to,:fetch_versions]
  skip_before_action :authorized, only: [:show,:index,:view_hidden_articles,:revert_to,:fetch_versions, :search_articles]
  before_action :set_paper_trail_whodunnit,only: [:update]
  before_action :check_condition, only: [:destroy, :update,:revert_to,:fetch_versions]
  before_action :check_search_attributes,only: [:search_articles]

  def index
    @articles = Article.where(status: "published",is_discarded: false)
    if @articles.present?
      return render json: {message: "Articles fetched successfully",articles: ArticleSerializer.new(@articles).serializable_hash}
    else
      return render json: {error: "Article not found"},status: 404
    end
  end
  
  def show
    if @article.present?
      return render json: {message: "Article fetched successfully",article: ArticleSerializer.new(@article).serializable_hash}
    else
      return render json: {error: "Article not found"},status: 404
    end
  end

  def view_hidden_articles
    @articles = Article.where(status: "hidden",is_discarded: false,user_id: current_user.id)
    if @articles.present?
      return render json: {message: "Hidden Articles fetched successfully",articles: ArticleSerializer.new(@articles).serializable_hash}
    else
      return render json: {error: "Hidden Article not found"},status: 404
    end
  end
  
  def create
    @article = Article.new(article_params)
    @article.user_id = current_user.id
    check_tag(params[:article][:tags_attributes])
    if @article.save
      cover_url = rails_blob_path(@article.cover, disposition: "attachment", only_path: true) if params[:article][:cover]
      return render json: {message: "Article successfully created",article: ArticleSerializer.new(@article).serializable_hash,cover_url: cover_url}
    else
      return render json: {error: "Article not created"},status: :unprocessable_entity
    end
  end

  def search_articles 
    @q = Article.ransack(
      status_eq: "published",
      is_discarded: false
    )
    @q.build_grouping(
      m: 'or',
      g: [
        { user_id_in: @user_ids},
        { category_id_in: @category_ids },
        { title_cont: params[:q][:title]},
        { created_at_eq: params[:q][:created_at]}
      ]
    )
    result = @q.result
    if result.present?
      result.paginate(:page => 1, :per_page => 10)
     return render json: {message: "Article fetched successfully",articles: ArticleSerializer.new(result).serializable_hash}
    else
      return render json: {error: "Not found"},status: 404
    end
  end

  def update
    if @article.update(article_params)
     return render json: {message: "Article successfully updated",article: ArticleSerializer.new(@article).serializable_hash}
    else
      return render json: {error: "Not updated"},status: :unprocessable_entity
    end
  end

  def destroy
    if @article.discard
      @article.update(is_discarded: true)
      return render json: {notice: "Article deleted successfully"},status: 200
    else
      return render json: {error: "not deleted"},status: :unprocessable_entity
    end
  end

  def fetch_versions
    version_number = @article.versions.where(event: "update").order(created_at: :desc).limit(5).pluck(:id).map.with_index { |id, index| ["Version #{index + 1}", id] }
    if version_number
      return render json: {version_number: version_number}
    else
      return render json: {error: "Not found"}
    end
  end

  def revert_to
    version_number = params[:version_id].to_i
    if @article.rollback_to(version_number)
      return render json: {message: "Article successfully reverted",article: ArticleSerializer.new(@article).serializable_hash}
    else
      return render json: {error: "Not reverted"},status: :unprocessable_entity
    end
  end

  
  private
  def article_params
    params.require(:article).permit(:title, :description, :category_id, :status,:cover)
  end

  def find_article
    @article = Article.find_by(id: params[:id])
    return render json: {error: "Article not found"},status: 404 unless @article
  end

  def check_condition
    return render json: {error: "You doesn't have access"} if current_user.id.to_i != @article.user_id
  end

  def check_search_attributes
    if params[:q][:author_name].present?
      @user_ids = User.where(first_name: params[:q][:author_name])&.pluck(:id)
    end
    if params[:q][:category_name].present?
      @category_ids = Category.where(name: params[:q][:category_name])&.pluck(:id)
    end
  end

  def check_tag(tag_params)
    return tag_params.present?
    tag_params.each do |params|
      tag_name = params[:name].downcase
      tag = @article.tags.find_by(name: tag_name)
  
      if tag
        @article.taggings.build(tag: tag)
      else
        @article.build_tagging_with_tag(params)
      end
    end
  end
   
end
