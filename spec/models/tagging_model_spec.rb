require 'rails_helper'

RSpec.describe Tagging, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:tag) }
    it { is_expected.to belong_to(:article) }
  end
end