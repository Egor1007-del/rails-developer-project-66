# frozen_string_literal: true

require Rails.root.join("test/stubs/github_client_stub") if Rails.env.test?
require Rails.root.join("test/stubs/repository_loader_stub") if Rails.env.test?
require Rails.root.join("test/stubs/rubocop_linter_stub") if Rails.env.test?
require Rails.root.join("test/stubs/eslint_linter_stub") if Rails.env.test?

class ApplicationContainer
  extend Dry::Container::Mixin

  if Rails.env.test?
    register(:github_client) { ::GithubClientStub }
    register(:repository_loader) { ::RepositoryLoaderStub.new }

    register(:linters) do
      {
        "ruby" => ::RubocopLinterStub.new,
        "javascript" => ::EslintLinterStub.new
      }
    end
  else
    register(:github_client) { ::GithubClient }
    register(:repository_loader) { ::RepositoryLoader.new }
    register(:linters) do
      {
        "ruby" => ::RubocopLinter.new,
        "javascript" => ::EslintLinter.new
      }
    end
  end

  register(:available_from_github) { ::Repositories::AvailableFromGithub.new }
  register(:build_from_github) { ::Repositories::BuildFromGithub.new }
end
