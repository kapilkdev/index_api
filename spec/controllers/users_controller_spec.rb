require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe "POST #create" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          first_name: "John",
          last_name: "Doe",
          email: "john@example.com",
          password: "password123"
        }
      end

      it "creates a new user" do
        expect {
          post :create, params: valid_params
        }.to change(User, :count).by(1)
        
      end

    end
  end
end
