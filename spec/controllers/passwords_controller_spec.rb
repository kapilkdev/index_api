require 'rails_helper'

RSpec.describe PasswordsController, type: :controller do
  describe 'Forgot# forgot_passwords' do
    let!(:user_password) {'Password@123'}

    let!(:user_params) do
      User.create(
        email: Faker::Internet.email,
        password: 'Password@123'
      )
    end

    context 'forgot #forgot_password' do
      it 'forgot password' do
        account = User.find_by(email: user_params.email)
        forgot_params = { email: account.email }
        post :forgot, params: forgot_params
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)).to include(
          'message' => 'We have sent you a token to reset your password.',
          'status' => 'ok',
        )
      end
    end
    context 'forgot #forgot_passwords' do
      it '#forgot' do
        forgot_params = { email: 'nil' }
        post :forgot, params: forgot_params
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'Reset#forgot_passwords' do
    let!(:user_password) {'Password@123'}
    
    let!(:account_params) do
      User.create(
        email:  Faker::Internet.email,
        password: 'Password@123',
        reset_password_token: 'dfghslffjsd',
        reset_password_sent_at: Time.zone.now
      )
    end


    context 'reset_password when valid token' do

      it 'reset password' do
        allow(User).to receive(:find_by).with('LOWER(email) = ? AND reset_password_token = ?', account_params.email.downcase, account_params.reset_password_token).and_return(account_params)

        reset_params = {
          token: account_params.reset_password_token,
          new_password: user_password,
          confirm_password: user_password,
          email: account_params.email
        }
        post :reset, params: reset_params
        expect(response).to have_http_status(200)
        response_body = JSON.parse(response.body, symbolize_names: true)
        expect(response_body[:message]).to eq('Your password has been successfuly reset!')
      end
    end

    context 'reset_password when invalid token' do
      it 'reset password for invalid token' do
        reset_param = { email: account_params.email, new_password: user_password, confirm_password: user_password}
        post :reset, params: reset_param
        expect(response).to have_http_status(404)
        response_body = JSON.parse(response.body, symbolize_names: true)
        expect(response_body[:error].first).to eq('Link not valid or expired. Try generating a new link.')
      end
    end

    context 'reset_password when invalid email' do
      it 'reset password for invalid email' do
        reset_params = {
          reset_password_token: 'nil',
          email: 'nil',
          new_password: user_password,
          confirm_password: user_password
        }
        session[:account_id] = nil
        post :reset, params: reset_params
        expect(response).to have_http_status(404)
      end
    end

    context 'reset_password when password are not matched' do
      it 'reset new password' do
        allow(User).to receive(:find_by).with(email: account_params.email, reset_password_token: account_params.reset_password_token).and_return(account_params)

        reset_params = {
          token: account_params.reset_password_token,
          new_password: 'Passwsord@123',
          confirm_password: user_password,
          email: account_params.email
        }
        post :reset, params: reset_params
        expect(response).to have_http_status(422)
        response_body = JSON.parse(response.body, symbolize_names: true)
        expect(response_body[:error]).to eq('Passwords are not matched')
      end
    end
  end
end
