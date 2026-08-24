require "test_helper"
require "minitest/mock"

class GithubClientTest < ActiveSupport::TestCase
  test "does not create webhook when it already exists" do
    repository_full_name = "example/repository"
    webhook_url = "https://example.com/api/checks"

    config = Struct.new(:url).new(webhook_url)
    hook = Struct.new(:config).new(config)

    octokit_client = Minitest::Mock.new
    octokit_client.expect(
      :hooks,
      [ hook ],
      [ repository_full_name ]
    )

    Octokit::Client.stub(:new, octokit_client) do
      client = GithubClient.new("token")

      client.install_webhook(
        repository_full_name,
        webhook_url
      )
    end

    octokit_client.verify
  end

  test "creates webhook when it does not exist" do
    repository_full_name = "example/repository"
    webhook_url = "https://example.com/api/checks"

    octokit_client = Minitest::Mock.new

    octokit_client.expect(
      :hooks,
      [],
      [ repository_full_name ]
    )

    octokit_client.expect(
      :create_hook,
      true,
      [
        repository_full_name,
        "web",
        {
          url: webhook_url,
          content_type: "json"
        },
        {
          events: [ "push" ],
          active: true
        }
      ]
    )

    Octokit::Client.stub(:new, octokit_client) do
      client = GithubClient.new("token")

      client.install_webhook(
        repository_full_name,
        webhook_url
      )
    end

    octokit_client.verify
  end
end
