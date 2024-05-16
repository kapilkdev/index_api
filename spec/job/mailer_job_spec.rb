require 'rails_helper'

RSpec.describe MailerJob, type: :job do
  describe "#perform" do
    include ActiveJob::TestHelper
    let!(:user) { create(:user, email: "user@example.com", password: "password123", ban: false) }

    it "queues the welcome email to be delivered later" do
  
      expect {
        MailerJob.perform_later(user)
      }.to have_enqueued_job.on_queue("default").exactly(:once)
    end
  end
end
