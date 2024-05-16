require 'rails_helper'
RSpec.describe Admin::AuthorsController, type: :controller do
  let!(:user) { create(:user, email: "user@example.com", password: "password123", ban: false) }
  let!(:admin_user) { create(:admin_user) }

  before do
    sign_in admin_user
  end

  describe "PUT #ban_author" do
    it "bans a user" do
      put :ban_author, params: { id: user.id }
      user.reload
      expect(user.ban).to eq(true)
      expect(response).to redirect_to(admin_authors_path)
      expect(flash[:notice]).to eq("Ban successfully")
    end
  end

  describe "PUT #un_ban" do
    before { user.update(ban: true) }

    it "un-bans a user" do
      put :un_ban, params: { id: user.id }
      user.reload
      expect(user.ban).to eq(false)
      expect(response).to redirect_to(admin_authors_path)
      expect(flash[:notice]).to eq("Un-Ban successfully")
    end
  end

  describe 'get to index' do
    context 'when data exist' do
      let!(:user) { create(:user, email: "user@example.com", password: "password123", ban: false) }

      it 'get request for index' do
        get :index
        expect(response).to be_successful
      end
    end

    context 'when data not exist' do
      it 'get request' do
        User.destroy_all
        get :index
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "GET #edit" do
    let!(:user) { create(:user, email: "user@example.com", password: "password123", ban: false) }

    it "renders the edit template" do
      get :edit, params: { id: user.id }
      expect(response).to have_http_status(200)
    end
  end
end