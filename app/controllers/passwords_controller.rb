class PasswordsController < ApplicationController
  skip_before_action :authorized, only: [:forgot,:reset]
  def forgot
    user = User.where('LOWER(email) = ?', params[:email].downcase).where(:ban => false).first
    if user
      user.send_password_reset
      render json: {
        message: "We have sent you a token to reset your password.", reset_token: user.reset_password_token, status: :ok
      }, status: :ok
    else
      render json: {
        message: "This email is not registered "
      }, status: :unprocessable_entity
    end
  end

  def reset
    if params[:new_password] == params[:confirm_password]
      user = User.find_by('LOWER(email) = ? AND reset_password_token = ?', params[:email].downcase,params[:token])
      if user.present? && user.password_token_valid?
          if user.update(password: params[:new_password])
            render json: {
              message: "Your password has been successfuly reset!",user: UserSerializer.new(user)
            }, status: :ok
          else
            render json: {
              message: "Account not found"
            }, status: :unprocessable_entity
          end
      else
        render json: {error:  ['Link not valid or expired. Try generating a new link.']}, status: :not_found
      end
    else
      return render json: { error: 'Passwords are not matched' }, status: :unprocessable_entity
    end
  end

end

