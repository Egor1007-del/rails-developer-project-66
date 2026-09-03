# frozen_string_literal: true

class RepositoryChecker
  include Import["repository_loader", "linters"]

  def call(check)
    loaded_repository = nil

    check.start!

    loaded_repository = repository_loader.call(check.repository)

    check.update!(
      commit_id: loaded_repository[:commit_id]
    )
    selected_linter = linters.fetch(check.repository.language.to_s)

    result = selected_linter.call(
      repository_path: loaded_repository[:path]
    )

    check.update!(
      output: result[:output],
      passed: result[:passed]
    )

    check.finish!

  rescue StandardError
    check.fail! if check.may_fail?
  ensure
    repository_loader.cleanup(loaded_repository[:path]) if loaded_repository
    send_notification(check)
  end

  private

  def send_notification(check)
    mailer = RepositoryCheckMailer.with(
      user: check.repository.user,
      check: check
    )
    if check.failed?
      mailer.error_check_email.deliver_later
    elsif !check.passed?
      mailer.failed_check_email.deliver_later
    end
  end
end
