require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let!(:user) { create(:user, email: "user@example.com", password: "password123", ban: false) }
  let!(:article) { create(:article, status: "published", is_discarded: false) }
  let(:comment_params) { { comment: { value: "Test comment" } } }

  describe "POST #create" do
    context "with valid parameters" do
      before do
        allow(controller).to receive(:current_user).and_return(user)
        post :create, params: { article_id: article.id }.merge(comment_params)
      end

      it "creates a new comment" do
        expect(Comment.count).to eq(1)
      end

      it "returns a success response with serialized comment" do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["notice"]).to eq("Comment was successfully created.")
        expect(JSON.parse(response.body)["comment"]["data"]["attributes"]["value"]).to eq("Test comment")
      end
    end

    context "with invalid parameters" do
      before do
        allow(controller).to receive(:current_user).and_return(user)
        post :create, params: { article_id: article.id, comment: { value: "" } }
      end

      it "does not create a new comment" do
        expect(Comment.count).to eq(0)
      end

      it "returns an error response" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("Comment not created")
      end
    end
  end

  describe "GET #show" do
    let(:comment) { create(:comment, article: article) }

    context "when comment exists" do
      before { get :show, params: { article_id: article.id,id: comment.id } }
      it "returns the comment" do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["notice"]).to eq("Comment was successfully fetched.")
        expect(JSON.parse(response.body)["comment"]["data"]["id"]).to eq("#{comment.id}")
      end
    end

    context "when comment does not exist" do
      before { get :show, params: { article_id: article.id, id: 999 } }

      it "returns an error response" do
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to eq("Comment not found")
      end
    end
  end
end

