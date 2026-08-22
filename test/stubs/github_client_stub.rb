# frozen_string_literal: true

class GithubClientStub
  GithubRepository = Struct.new(
    :id,
    :name,
    :full_name,
    :language,
    :clone_url,
    :ssh_url,
    keyword_init: true
  )

  RUBY_REPOSITORY = GithubRepository.new(
    id: 10_001,
    name: "github-rails-project",
    full_name: "user-one/github-rails-project",
    language: "Ruby",
    clone_url: "https://github.com/user-one/github-rails-project.git",
    ssh_url: "git@github.com:user-one/github-rails-project.git"
  )

  JAVASCRIPT_REPOSITORY = GithubRepository.new(
    id: 20_001,
    name: "javascript-project",
    full_name: "user-one/javascript-project",
    language: "JavaScript",
    clone_url: "https://github.com/user-one/javascript-project.git",
    ssh_url: "git@github.com:user-one/javascript-project.git"
  )

  PYTHON_REPOSITORY = GithubRepository.new(
    id: 30_001,
    name: "python-project",
    full_name: "user-one/python-project",
    language: "Python",
    clone_url: "https://github.com/user-one/python-project.git",
    ssh_url: "git@github.com:user-one/python-project.git"
  )

  def initialize(_token)
  end

  def repositories
    [ RUBY_REPOSITORY, JAVASCRIPT_REPOSITORY, PYTHON_REPOSITORY ]
  end

  def repository(github_id)
    repositories.find do |repo|
      repo.id == github_id.to_i
    end
  end
end
