ENV["RAILS_ENV"] ||= "test"
ENV["BASE_URL"] ||= "localhost:3000"
ENV["GITHUB_WEBHOOK_SECRET"] = "test-webhook-secret"

require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"
require_relative "stubs/github_client_stub"
require "webmock/minitest"

WebMock.disable_net_connect!(allow_localhost: true)

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
  end
end
