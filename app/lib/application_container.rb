# frozen_string_literal: true

require Rails.root.join("test/stubs/github_client_stub") if Rails.env.test?
require Rails.root.join("test/stubs/repository_loader_stub") if Rails.env.test?
require Rails.root.join("test/stubs/rubocop_linter_stub") if Rails.env.test?

class ApplicationContainer
  extend Dry::Container::Mixin

  if Rails.env.test?
    register(:github_client) { ::GithubClientStub }
    register(:repository_loader) { ::RepositoryLoaderStub.new }
    register(:linter) { ::RubocopLinterStub.new }
  else
    register(:github_client) { ::GithubClient }
    register(:repository_loader) { ::RepositoryLoader.new }
    register(:linter) { ::RubocopLinter.new }
  end
end
