class UsersController < ApplicationController
  include Rails.application.routes.url_helpers
  skip_before_action :authorized, only: [:create]
  # rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
  def create
    user = User.new(user_params)
    if user.save
      @token = encode_token(user_id: user.id)
      cover_url = rails_blob_path(user.avatar, disposition: "attachment", only_path: true) if params[:avatar]
      MailerJob.set(wait_until: Time.now+ 5.seconds).perform_later(user)
      render json: {
        user: UserSerializer.new(user), 
        token: @token,
        imgae: cover_url
      }, status: :created
    else
      retuen render json: {error: "Doesn't create"},status: :unprocessable_entity
    end
  end

  private
  def user_params 
    params.permit(:first_name,:last_name,:email,:password,:avatar)
  end

  def handle_invalid_record(e)
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end
end
