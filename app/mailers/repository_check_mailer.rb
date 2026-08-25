class RepositoryCheckMailer < ApplicationMailer
  def check_failed(check)
    @check = check

    mail to: check.repository.user.email
  end
end
