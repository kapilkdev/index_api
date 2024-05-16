class MailerJob < ApplicationJob
  queue_as :default

  def perform(user)
    ConfirmationMailer.welcome_email(user).deliver_later
  end
end
