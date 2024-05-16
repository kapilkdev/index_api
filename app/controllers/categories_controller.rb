class CategoriesController < ApplicationController
  skip_before_action :authorized, only: [:index]
  def index
    @categories = Category.all
    if @categories.present?
      return render json: {message: "Category successfully fetched",categories: @categories}
    else
      return render json: {error: "Not found"}
    end
  end
end
