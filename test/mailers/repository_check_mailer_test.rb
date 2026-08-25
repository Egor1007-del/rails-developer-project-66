require "test_helper"

class RepositoryCheckMailerTest < ActionMailer::TestCase
  setup do
    @repository = repositories(:one)
    @check = @repository.checks.create!(
      aasm_state: "finished",
      passed: false
    )
  end

  test "check failed email" do
    email = RepositoryCheckMailer.check_failed(@check)

    assert_equal [ @repository.user.email ], email.to
    assert_equal I18n.t(
      "repository_check_mailer.check_failed.subject"
    ), email.subject

    assert_match @repository.full_name, email.text_part.body.to_s
    assert_match "http", email.text_part.body.to_s
  end
end
