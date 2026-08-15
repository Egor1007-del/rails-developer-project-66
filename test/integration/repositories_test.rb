require "test_helper"

class RepositoriesTest < ActionDispatch::IntegrationTest
  GithubRepository = Struct.new(
    :id,
    :name,
    :full_name,
    :language,
    :clone_url,
    :ssh_url,
    keyword_init: true
  )

  class GithubClientStub
    def initialize(repository)
      @repository = repository
    end

    def repositories
      [ @repository ]
    end

    def repository(_github_id)
      @repository
    end
  end

  setup do
    @user = users(:one)
    @other_user = users(:two)

    @github_repository = GithubRepository.new(
      id: 10_001,
      name: "github-rails-project",
      full_name: "user-one/github-rails-project",
      language: "Ruby",
      clone_url: "https://github.com/user-one/github-rails-project.git",
      ssh_url: "git@github.com:user-one/github-rails-project.git"
    )

    @github_client = GithubClientStub.new(@github_repository)
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
                  text: I18n.t("repositories.index.add")

    assert_select "a[href='#{repository_path(own_repository)}']",
                  text: own_repository.name

    assert_select "a[href='#{repository_path(other_repository)}']",
                  count: 0
  end

  test "new displays github repositories in select" do
    sign_in(@user)

    GithubClient.stub(:new, @github_client) do
      get new_repository_path
    end

    assert { response.successful? }

    assert_select "h1",
                  text: I18n.t("repositories.new.title")

    assert_select "select[name='repository[github_id]']" do
      assert_select "option[value='#{@github_repository.id}']",
                    text: @github_repository.full_name
    end

    assert_select "input[type='submit']",
                  value: I18n.t("repositories.new.submit")
  end

  test "user creates repository" do
    sign_in(@user)

    assert_difference -> { @user.repositories.count }, 1 do
      GithubClient.stub(:new, @github_client) do
        post repositories_path,
            params: {
              repository: {
                github_id: @github_repository.id
              }
            }
      end
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

  test "show displays repository full name as heading" do
    sign_in(@user)

    repository = repositories(:one)

    get repository_path(repository)

    assert { response.successful? }

    assert_select "h1",
                  text: repository.full_name
  end

  test "user cannot view another users repository" do
    sign_in(@user)

    other_repository = repositories(:two)

    get repository_path(other_repository)

    assert { response.status == 404 }
  end

  test "user cannot create repository with unsupported language" do
    sign_in(@user)

    github_repository = GithubRepository.new(
      id: 20_001,
      name: "javascript-project",
      full_name: "user-one/javascript-project",
      language: "JavaScript",
      clone_url: "https://github.com/user-one/javascript-project.git",
      ssh_url: "git@github.com:user-one/javascript-project.git"
    )

    github_client = GithubClientStub.new(github_repository)

    repositories_count = @user.repositories.count

    GithubClient.stub(:new, github_client) do
      post repositories_path,
          params: {
            repository: {
              github_id: github_repository.id
            }
          }
    end

    assert { response.status == 422 }
    assert { @user.repositories.count == repositories_count }

    assert do
      @user.repositories.find_by(
        github_id: github_repository.id
      ).nil?
    end

    assert_select "input[type='submit']",
                  value: I18n.t("repositories.new.submit")
  end

  test "user cannot add same github repository twice" do
    sign_in(@user)

    existing_repository = repositories(:one)

    github_repository = GithubRepository.new(
      id: existing_repository.github_id,
      name: existing_repository.name,
      full_name: existing_repository.full_name,
      language: "Ruby",
      clone_url: existing_repository.clone_url,
      ssh_url: existing_repository.ssh_url
    )

    github_client = GithubClientStub.new(github_repository)

    repositories_count = @user.repositories.count

    GithubClient.stub(:new, github_client) do
      post repositories_path,
          params: {
            repository: {
              github_id: github_repository.id
            }
          }
    end

    assert { response.status == 422 }
    assert { @user.repositories.count == repositories_count }

    assert do
      @user.repositories.where(
        github_id: github_repository.id
      ).count == 1
    end

    assert_select "input[type='submit']",
                  value: I18n.t("repositories.new.submit")
  end

  private

  def sign_in(user)
    post "/test/session", params: { email: user.email }

    assert { response.successful? }
  end
end
