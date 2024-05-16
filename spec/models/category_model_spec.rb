require 'rails_helper'

RSpec.describe Category, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:articles).dependent(:destroy) }
  end

  describe "scopes" do
    it "should allow ransackable attributes" do
      expect(described_class.ransackable_attributes).to match_array(["id", "name"])
    end
  end
end