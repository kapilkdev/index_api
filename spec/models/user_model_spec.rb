require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user, email: "user@example.com", password: "password123", ban: false) }
  describe "associations" do
    it { is_expected.to have_many(:articles).dependent(:destroy) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:email) }
  end


  describe "scopes" do
    it "should allow ransackable attributes" do
      expect(described_class.ransackable_attributes).to match_array(["id", "first_name", "last_name", "email", "ban"])
    end
  end
end