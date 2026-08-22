require "test_helper"

class Web::RepositoriesTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)

    @github_repository = GithubClientStub::RUBY_REPOSITORY
  end

  test "guest cannot view repository pages" do
    paths = [
      repositories_path,
      new_repository_path,
      repository_path(repositories(:one))
    ]

    paths.each do |path|
      get path

      assert { response.redirect? }
      assert { response.location == root_url }
    end
  end
  test "guest cannot create repository" do
    post repositories_path,
        params: {
          repository: {
            github_id: 10_001
          }
        }

    assert { response.redirect? }
    assert { response.location == root_url }
    assert { Repository.where(github_id: 10_001).none? }
  end

  test "user sees only own repositories" do
    sign_in(@user)

    own_repository = repositories(:one)
    other_repository = repositories(:two)

    get repositories_path

    assert { response.successful? }

    assert_select "a[href='#{new_repository_path}']",
                  text: I18n.t("web.repositories.index.add")

    assert_select "a[href='#{repository_path(own_repository)}']",
                  text: own_repository.name

    assert_select "a[href='#{repository_path(other_repository)}']",
                  count: 0
  end

  test "new displays github repositories in select" do
    sign_in(@user)


    get new_repository_path

    assert { response.successful? }

    assert_select "h1",
                  text: I18n.t("web.repositories.new.title")

    assert_select "select[name='repository[github_id]']" do
      assert_select "option[value='#{@github_repository.id}']",
                    text: @github_repository.full_name
    end

    assert_select "input[type='submit']",
                  value: I18n.t("web.repositories.new.submit")
  end

  test "user creates repository" do
    sign_in(@user)

    assert_difference -> { @user.repositories.count }, 1 do
      post repositories_path,
          params: {
            repository: {
              github_id: @github_repository.id
            }
          }
    end

    assert { response.redirect? }
    assert { response.location == repositories_url }

    repository =
      @user.repositories.find_by(
        github_id: @github_repository.id
      )

    assert { repository.present? }
    assert { repository.name == @github_repository.name }
    assert { repository.full_name == @github_repository.full_name }
    assert { repository.language.ruby? }
    assert { repository.clone_url == @github_repository.clone_url }
    assert { repository.ssh_url == @github_repository.ssh_url }
    follow_redirect!

    assert { response.successful? }

    assert_select "a[href='#{repository_path(repository)}']",
                  text: repository.name
  end

  test "show displays repository full name as heading and check button" do
    sign_in(@user)

    repository = repositories(:one)

    get repository_path(repository)

    assert { response.successful? }

    assert_select "h1",
                  text: repository.full_name

    assert_select "form[action='#{repository_checks_path(repository)}']" do
      assert_select "button",
                    text: I18n.t("web.repositories.show.check")
    end
  end

  test "user cannot view another users repository" do
    sign_in(@user)

    other_repository = repositories(:two)

    get repository_path(other_repository)

    assert { response.status == 404 }
  end

  test "user cannot create repository with unsupported language" do
    sign_in(@user)

    github_repository = GithubClientStub::PYTHON_REPOSITORY

    repositories_count = @user.repositories.count


    post repositories_path,
        params: {
          repository: {
            github_id: github_repository.id
          }
        }


    assert { response.status == 422 }
    assert { @user.repositories.count == repositories_count }

    assert do
      @user.repositories.find_by(
        github_id: github_repository.id
      ).nil?
    end

    assert_select "input[type='submit']",
                  value: I18n.t("web.repositories.new.submit")
  end

  test "user cannot add same github repository twice" do
    sign_in(@user)

    existing_repository = repositories(:one)

    github_repository = GithubClientStub::RUBY_REPOSITORY

    existing_repository.update!(
      github_id: github_repository.id
    )

    repositories_count = @user.repositories.count

    post repositories_path,
        params: {
          repository: {
            github_id: github_repository.id
          }
        }

    assert { response.status == 422 }
    assert { @user.repositories.count == repositories_count }

    assert do
      @user.repositories.where(
        github_id: github_repository.id
      ).count == 1
    end

    assert_select "input[type='submit']",
                  value: I18n.t("web.repositories.new.submit")
  end

  test "index displays latest repository check result" do
    sign_in(@user)

    repository = repositories(:one)
    repository.checks.delete_all

    repository.checks.create!(
      aasm_state: "finished",
      passed: false,
      commit_id: "old123",
      output: "{}"
    )

    repository.checks.create!(
      aasm_state: "finished",
      passed: true,
      commit_id: "new456",
      output: "{}"
    )

    get repositories_path

    assert { response.successful? }

    assert_select "th",
                  text: I18n.t(
                    "web.repositories.index.last_check_status"
                  )

    assert_select "td", text: "true", count: 1
    assert_select "td", text: "false", count: 0
  end

  private

  def sign_in(user)
    post "/test/session", params: { email: user.email }

    assert { response.successful? }
  end
end
