# frozen_string_literal: true

require Rails.root.join("test/stubs/github_client_stub") if Rails.env.test?

class ApplicationContainer
  extend Dry::Container::Mixin

  if Rails.env.test?
    register(:github_client) { ::GithubClientStub }
  else
    register(:github_client) { ::GithubClient }
  end
end
