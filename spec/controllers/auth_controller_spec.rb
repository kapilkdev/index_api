require 'rails_helper'

RSpec.describe AuthController, type: :controller do
  
  
  describe "POST #login" do
    let(:user) { create(:user, email: "user@example.com", password: "password123", ban: false) }

    context "with valid credentials" do
      it "logs in the user and returns a token" do
        post :login, params: { email: user.email, password: "password123" }
        expect(response).to have_http_status(:accepted)
        json_response = JSON.parse(response.body)
        expect(json_response["user"]["email"]).to eq(user.email)
        expect(json_response["token"]).to be_present
      end
    end

    context "when user is banned" do
      it "returns an error message" do
        user.update(ban: true)
        post :login, params: { email: user.email, password: "password123" }
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Can not login!!Banned by admin")
      end
    end


    context "with incorrect password" do
      it "returns an incorrect password message" do
        post :login, params: { email: user.email, password: "incorrectpassword" }
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Incorrect password")
      end
    end
  end

end
