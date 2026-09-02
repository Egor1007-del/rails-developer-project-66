require "test_helper"

class Web::Repositories::ChecksTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @repository = repositories(:one)
  end

  test "user creates repository check" do
    sign_in(@user)

    existing_ids = @repository.checks.ids

    assert_enqueued_with(job: RepositoryCheckJob) do
      post repository_checks_path(@repository)
    end

    assert { response.redirect? }
    assert { response.location == repository_url(@repository) }

    check = @repository.checks.where.not(id: existing_ids).first

    assert check
    assert { check.created? }
  end

  test "user views repository check" do
    sign_in(@user)

    check = @repository.checks.create!

    get repository_check_path(@repository, check)

    assert { response.successful? }

    assert_select "h1",
                  text: I18n.t(
                    "web.repositories.checks.show.title",
                    id: check.id
                  )

    assert_select "a[href='#{repository_path(@repository)}']",
                  text: I18n.t(
                    "web.repositories.checks.show.back"
                  )
  end

  test "user checks javascript repository with eslint" do
    sign_in(@user)

    repository = repositories(:three)

    perform_enqueued_jobs(only: RepositoryCheckJob) do
      post repository_checks_path(repository)
    end

    assert { response.redirect? }
    assert { response.location == repository_url(repository) }

    check = repository.checks.order(:created_at).last

    assert check
    assert { check.finished? }
    assert { check.passed == false }
    assert { check.commit_id == RepositoryLoaderStub::COMMIT_ID }
    assert { check.output == EslintLinterStub::OUTPUT }
    assert { check.offense_count == 1 }

    get repository_check_path(repository, check)

    assert { response.successful? }

    assert_select "td.fw-bold",
                  text: "/tmp/repository/app.js"

    assert_select "td",
                  text: "'userName' is not defined."

    assert_select "td",
                  text: "no-undef"

    assert_select "td",
                  text: "2:13"
  end
end
