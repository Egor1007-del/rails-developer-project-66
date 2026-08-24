class InstallWebhook
  include Import[:github_client]

  def call(user:, repository:)
    client = github_client.new(user.token)

    webhook_url = Rails.application.routes.url_helpers.api_checks_url

    webhook_secret = ENV.fetch("GITHUB_WEBHOOK_SECRET")

    client.install_webhook(
      repository.full_name,
      webhook_url,
      webhook_secret
    )
  end
end
