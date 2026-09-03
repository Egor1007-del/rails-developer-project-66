# frozen_string_literal: true

class ApplicationContainer
  extend Dry::Container::Mixin

  if Rails.env.test?
    register(:github_client) { Stubs::GithubClientStub }
    register(:repository_loader) { Stubs::RepositoryLoaderStub.new }

    register(:linters) do
      {
        "ruby" => Stubs::RubocopLinterStub.new,
        "javascript" => Stubs::EslintLinterStub.new
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
end
