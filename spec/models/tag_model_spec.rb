require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:taggings) }
    it { is_expected.to have_many(:articles).through(:taggings) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "callbacks" do
    it "should downcase the name before validation" do
      tag = FactoryBot.build(:tag, name: "HELLO")
      tag.valid?
      expect(tag.name).to eq("hello")
    end
  end
end