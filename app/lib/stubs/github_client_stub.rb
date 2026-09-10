# frozen_string_literal: true

module Stubs
  class GithubClientStub
    class << self
      attr_accessor :installed_webhooks

      def reset_webhooks!
        installed_webhooks.clear
      end
    end

    def initialize(*); end

    def repositories
      data = JSON.parse(
        Rails.root.join(
          "test/fixtures/files/user_repositories.json"
        ).read,
        symbolize_names: true
      )

      data.map do |params|
        GithubRepositoryStub.new(params)
      end
    end

    def repository(github_id)
      repositories.find do |repo|
        repo.id == github_id.to_i
      end
    end

    self.installed_webhooks = []

    def install_webhook(repository_full_name, webhook_url, webhook_secret)
      self.class.installed_webhooks << {
        repository_full_name:,
        webhook_url:,
        webhook_secret:
      }

      true
    end
  end
end
