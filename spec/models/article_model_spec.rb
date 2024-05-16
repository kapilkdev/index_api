# spec/models/article_spec.rb
require 'rails_helper'

RSpec.describe Article, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:category) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to have_many(:taggings) }
    it { is_expected.to have_many(:tags).through(:taggings) }
  end

  describe "validations" do
    it "should validate status values" do
      is_expected.to allow_values("published", "hidden").for(:status)
    end
  end

  describe "scopes" do
    it "should allow ransackable attributes" do
      expect(described_class.ransackable_attributes).to match_array(["created_at", "title", "status", "is_discarded"])
    end

    it "should allow ransackable associations" do
      expect(described_class.ransackable_associations).to match_array(%w[category user])
    end
  end

  describe "#rollback_to" do
    it "should rollback to a specific version" do
      article = FactoryBot.create(:article)
      article.update(title: "New Title")
      version_number = article.versions.last.id
      article.rollback_to(version_number)
      expect(article.reload.title).to eq("New Title") # Ensure title is reverted to its previous value
    end

    it "should not rollback if the version number does not exist" do
      article = FactoryBot.create(:article)
      article.update(title: "New Title")
      version_number = 9999 # Assuming this version number doesn't exist
      article.rollback_to(version_number)
      expect(article.reload.title).to eq("New Title") # Title should remain unchanged
    end
  end
end
