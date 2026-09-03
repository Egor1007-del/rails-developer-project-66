require "test_helper"

class RepositoryCheckMailerTest < ActionMailer::TestCase
  setup do
    @repository = repositories(:one)
  end

  test "error check email" do
    check = @repository.checks.create!(
      aasm_state: "failed",
      passed: nil
    )

    email = RepositoryCheckMailer.with(
      user: @repository.user,
      check: check
    ).error_check_email

    assert_equal [ @repository.user.email ], email.to

    assert_equal I18n.t(
      "repository_check_mailer.error_check_email.subject"
    ), email.subject

    assert_match @repository.full_name, email.text_part.body.to_s
    assert_match "http", email.text_part.body.to_s
  end

  test "failed check email" do
    check = @repository.checks.create!(
      aasm_state: "finished",
      passed: false
    )

    email = RepositoryCheckMailer.with(
      user: @repository.user,
      check: check
    ).failed_check_email

    assert_equal [ @repository.user.email ], email.to

    assert_equal I18n.t(
      "repository_check_mailer.failed_check_email.subject"
    ), email.subject

    assert_match @repository.full_name, email.text_part.body.to_s
    assert_match "http", email.text_part.body.to_s
  end
end
