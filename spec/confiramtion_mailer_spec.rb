require "rails_helper"

RSpec.describe ConfirmationMailer, type: :mailer do
  describe "welcome_email" do
    let(:user) { create(:user, email: "test@example.com", password: "Password@123", first_name: "someone1") }
    let(:mail) { ConfirmationMailer.welcome_email(user) }

    it "renders the headers" do
      expect(mail.subject).to eq("Welcome to My Awesome Site")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["index@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("Welcome")
      expect(mail.body.encoded).to include("Thanks for joining and have a great day!")
    end
  end
end