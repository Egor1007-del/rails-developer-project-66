# Preview all emails at http://localhost:3000/rails/mailers/repository_check_mailer
class RepositoryCheckMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/repository_check_mailer/check_failed
  def check_failed
    RepositoryCheckMailer.check_failed
  end
end
