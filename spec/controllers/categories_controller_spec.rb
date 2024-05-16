require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  describe "GET #index" do
    context "when categories exist" do
      let!(:categories) { create_list(:category, 3) }

      it "returns a successful response with categories" do
        get :index
        expect(response).to have_http_status(:success) 
        expect(JSON.parse(response.body)["message"]).to eq("Category successfully fetched")
        expect(JSON.parse(response.body)["categories"].count).to eq(3)
      end
    end

    context "when no categories exist" do
      it "returns an error message" do
        get :index
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)["error"]).to eq("Not found")
      end
    end
  end
end