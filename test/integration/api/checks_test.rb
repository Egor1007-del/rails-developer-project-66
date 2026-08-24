require "test_helper"
require "openssl"

class Api::ChecksTest < ActionDispatch::IntegrationTest
  setup do
    @repository = repositories(:one)
  end
  test "creates and runs repository check for valid push event" do
    payload = {
      repository: {
        full_name: @repository.full_name
      }
    }.to_json

    assert_difference -> { @repository.checks.count }, 1 do
      post api_checks_path,
           params: payload,
           headers: webhook_headers("push", payload)
    end

    assert_response :success

    check = @repository.checks.order(:created_at).last

    assert { check.finished? }
    assert { check.passed == true }
    assert { check.commit_id.present? }
    assert { check.output.present? }
  end

  test "does not create repository check for ping event" do
    payload = {
      repository: {
        full_name: @repository.full_name
      }
    }.to_json

    assert_no_difference -> { @repository.checks.count } do
      post api_checks_path,
           params: payload,
           headers: webhook_headers("ping", payload)
    end

    assert_response :success
  end

  test "rejects request with invalid signature" do
    payload = {
      repository: {
        full_name: @repository.full_name
      }
    }.to_json

    headers = webhook_headers("push", payload)
    headers["X-Hub-Signature-256"] = "sha256=invalid"

    assert_no_difference -> { @repository.checks.count } do
      post api_checks_path,
           params: payload,
           headers: headers
    end

    assert_response :unauthorized
  end

  private

  def webhook_headers(event, payload)
    {
      "Content-Type" => "application/json",
      "X-GitHub-Event" => event,
      "X-Hub-Signature-256" => webhook_signature(payload)
    }
  end

  def webhook_signature(payload)
    digest = OpenSSL::HMAC.hexdigest(
      "SHA256",
      ENV.fetch("GITHUB_WEBHOOK_SECRET"),
      payload
    )

    "sha256=#{digest}"
  end
end
