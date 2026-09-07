class RepositoryCheckMailer < ApplicationMailer
  def error_check_email
    @check = params[:check]
    @user = params[:user]

    mail(
      to: @user.email,
      subject: t(".subject")
    )
  end

  def failed_check_email
    @check = params[:check]
    @user = params[:user]

    @check_result = LogFormatter.format(
      @check.output,
      @check.repository.language
    )

    mail(
      to: @user.email,
      subject: t(".subject")
    )
  end
end
