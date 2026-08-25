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

    RepositoryCheckMailer.check_failed(check).deliver_later unless check.passed?

  rescue StandardError
    check.fail! if check.may_fail?
    RepositoryCheckMailer.check_failed(check).deliver_later
    raise
  ensure
    if loaded_repository
      repository_loader.cleanup(loaded_repository[:path])
    end
  end
end
