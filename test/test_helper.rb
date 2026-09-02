ENV["RAILS_ENV"] ||= "test"
ENV["BASE_URL"] ||= "localhost:3000"
ENV["GITHUB_WEBHOOK_SECRET"] = "test-webhook-secret"

require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"
require_relative "stubs/github_client_stub"
require "webmock/minitest"

ActiveJob::Base.queue_adapter = :test

WebMock.disable_net_connect!(allow_localhost: true)

OmniAuth.config.test_mode = true

module AuthenticationTestHelper
  def sign_in(user)
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      provider: user.provider,
      uid: user.uid,
      info: {
        nickname: user.nickname,
        name: user.name,
        email: user.email,
        image: user.image_url
      },
      credentials: {
        token: user.token
      }
    )

    get "/auth/github/callback"
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
  end
end

class ActionDispatch::IntegrationTest
  include AuthenticationTestHelper
end
