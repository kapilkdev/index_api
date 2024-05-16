require 'rails_helper'

RSpec.describe ArticlesController, type: :controller do
  describe "GET #index" do
    let!(:user) { create(:user, email: "user@example.com", password: "password123", ban: false) }
    let!(:article) { create(:article, status: "published", is_discarded: false) }
    
    context "when articles exist" do
      it "returns a successful response with articles" do
        get :index
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)["message"]).to eq("Articles fetched successfully")
        expect(JSON.parse(response.body)["articles"].count).to eq(1)
      end
    end

    context "when no articles exist" do
      it "returns an error message" do
        Article.destroy_all
        get :index
        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)["error"]).to eq("Article not found")
      end
    end
  end

  describe "GET #show" do
    let!(:article) { create(:article) }

    context "when article exists" do
      it "returns a successful response with the article" do
        get :show, params: { id: article.id }
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)["message"]).to eq("Article fetched successfully")
        expect(JSON.parse(response.body)["article"]["data"]["id"]).to eq("#{article.id}")
      end
    end

    context "when article does not exist" do
      it "returns an error message" do
        get :show, params: { id: "non_existent_id" }
        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)["error"]).to eq("Article not found")
      end
    end
  end

  describe "GET #search_articles" do
    context "when articles are found" do
      let(:user) { create(:user, email: "user@example.com", password: "password123", ban: false) }
      let!(:category) { create(:category) }
      let!(:articles) { create_list(:article, 3, status: "published", is_discarded: false, user: user, category: category) }

      it "returns a successful response with articles" do
        get :search_articles, params: { q: { title: "Sample", author_name: user.first_name, category_name: category.name } }
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)["message"]).to eq("Article fetched successfully")
        expect(JSON.parse(response.body)["articles"].count).to eq(1)
      end
    end

    context "when no articles are found" do
      it "returns an error message" do
        get :search_articles, params: { q: { title: "Non-existent Title" } }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to eq("Not found")
      end
    end
  end

  describe "GET #view_hidden_articles" do
    context "when hidden articles are found" do
      let(:user) { create(:user, email: "user@example.com", password: "password123", ban: false) }
      let!(:hidden_articles) { create_list(:article, 3, status: "hidden", is_discarded: false, user: user) }

      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      it "returns a successful response with hidden articles" do
        get :view_hidden_articles
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)["message"]).to eq("Hidden Articles fetched successfully")
        expect(JSON.parse(response.body)["articles"].count).to eq(1)
      end
    end

    context "when no hidden articles are found" do
      let(:user) { create(:user, email: "user@example.com", password: "password123", ban: false) }

      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      it "returns an error message" do
        get :view_hidden_articles
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to eq("Hidden Article not found")
      end
    end
  end


  describe "POST #create" do
    let(:user) { create(:user, email: "user@example.com", password: "password123", ban: false) }
    let(:valid_attributes) { attributes_for(:article) }
    let(:invalid_attributes) { attributes_for(:article, title: nil) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context "with valid parameters" do
      it "creates a new article" do
        expect {
          post :create, params: { article: valid_attributes }
        }.to change(Article, :count).by(1)
      end

      it "returns a success response with the created article" do
        post :create, params: { article: valid_attributes }
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)["message"]).to eq("Article successfully created")
        expect(JSON.parse(response.body)["article"]["data"]["attributes"]["title"]).to eq(valid_attributes[:title])
      end
    end
  end


  describe "PUT #update" do
    let(:user) { create(:user, email: "user@example.com", password: "password123", ban: false) }
    let(:article) { create(:article, user: user) }
    let(:valid_attributes) { attributes_for(:article, user_id: user.id) }
    let(:invalid_attributes) { attributes_for(:article, title: "") }

    before { allow(controller).to receive(:current_user).and_return(user) }

    context "with valid params" do
      before { put :update, params: { id: article.id, article: valid_attributes } }

      it "updates the requested article" do
        article.reload
        expect(article.title).to eq(valid_attributes[:title])
      end

      it "renders a JSON response with the updated article" do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to eq("Article successfully updated")
        expect(JSON.parse(response.body)["article"]["data"]["attributes"]["title"]).to eq(valid_attributes[:title])
      end
    end

  end
  
  describe "DELETE #destroy" do
    let!(:user) { create(:user, email: "user@example.com", password: "password123", ban: false) }
    let!(:article) { create(:article, user: user) }
    before { allow(controller).to receive(:current_user).and_return(user) }
    context "when article is successfully discarded" do
      before { delete :destroy, params: { id: article.id } }

      it "discards the requested article" do
        article.reload
        expect(article.is_discarded).to eq(true)
      end

      it "renders a JSON response with a success message" do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["notice"]).to eq("Article deleted successfully")
      end
    end
  end


  describe "GET #fetch_versions" do
    let!(:user) { create(:user, email: "user@example.com", password: "password123", ban: false) }
    let(:article) { create(:article, user: user) }

    before { allow(controller).to receive(:current_user).and_return(user) }
    context "when article versions are successfully fetched" do
      before { get :fetch_versions, params: { id: article.id } }

      it "returns a JSON response with version numbers" do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to have_key("version_number")
      end
    end
  end

  

  describe "POST #revert_to" do
    let!(:user) { create(:user, email: "user@example.com", password: "password123", ban: false) }
    let!(:article) { create(:article, user: user) }
    let!(:version_id) { 1 }

    before { allow(controller).to receive(:current_user).and_return(user) }
    context "when article is successfully reverted" do
      
      before do
        article.update(title: "updated")
        version_id = article.versions.last.id
        post :revert_to, params: { id: article.id, version_id: version_id }
      end

      it "returns a JSON response with a success message" do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to eq("Article successfully reverted")
      end
    end

    context "when article cannot be reverted" do
      before do
        allow(article).to receive(:rollback_to).with(version_id).and_return(false)
        post :revert_to, params: { id: article.id, version_id: version_id }
      end

      it "returns a JSON response with an error message" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("Not reverted")
      end
    end
  end


end
