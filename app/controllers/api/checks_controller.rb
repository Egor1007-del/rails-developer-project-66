module Api
  class ChecksController < ApplicationController
    skip_forgery_protection only: :create
    before_action :verify_webhook_signature!

    def create
      return head :ok unless push_event?

      repository = Repository.find_by!(
        full_name: repository_params[:full_name]
      )

      check = repository.checks.create!

      RepositoryCheckJob.perform_later(check)

      head :ok
    end

    private

    def verify_webhook_signature!
      webhook_secret = ENV["GITHUB_WEBHOOK_SECRET"]

      return if webhook_secret.blank?

      signature =
        request.headers["X-Hub-Signature-256"]

      return head :unauthorized if signature.blank?

      expected_signature = OpenSSL::HMAC.hexdigest(
        "SHA256",
        ENV.fetch("GITHUB_WEBHOOK_SECRET"),
        request.raw_post
      )

      expected_signature = "sha256=#{expected_signature}"

      return if ActiveSupport::SecurityUtils.secure_compare(
        expected_signature,
        signature
      )

      head :unauthorized
    end

    def repository_params
      params.require(:repository).permit(:full_name)
    end

    def push_event?
      request.headers["X-GitHub-Event"] == "push"
    end
  end
end
