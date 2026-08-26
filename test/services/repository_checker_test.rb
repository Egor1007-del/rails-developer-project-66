require "test_helper"

class RepositoryCheckTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @repository = repositories(:one)
    @repository.update!(language: "ruby")
    @check = @repository.checks.create!
  end

  test "does not send email when check passes" do
    successful_linter = lambda do |repository_path:|
      {
        output: '{"files":[]}',
        passed: true
      }
    end

    checker = RepositoryChecker.new(
      linters: { "ruby" => successful_linter }
    )

    assert_no_enqueued_emails do
      checker.call(@check)
    end

    assert { @check.reload.finished? }
    assert { @check.passed == true }
  end

  test "sends email when linter finds errors" do
    linter_with_errors = lambda do |repository_path:|
      {
        output: '{"files":[]}',
        passed: false
      }
    end

    checker = RepositoryChecker.new(
      linters: { "ruby" => linter_with_errors }
    )

    assert_enqueued_emails 1 do
      checker.call(@check)
    end

    assert { @check.reload.finished? }
    assert { @check.passed == false }
  end

  test "sends email when check fails with exception" do
    broken_linter = lambda do |repository_path:|
      raise "Linter failed"
    end

    checker = RepositoryChecker.new(
      linters: { "ruby" => broken_linter }
    )

    assert_enqueued_emails 1 do
      error = assert_raises RuntimeError do
        checker.call(@check)
      end

      assert { error.message == "Linter failed" }
    end

    assert { @check.reload.failed? }
    assert { @check.passed.nil? }
  end
end
