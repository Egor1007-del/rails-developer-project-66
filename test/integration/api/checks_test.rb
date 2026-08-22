require "test_helper"

class Api::ChecksTest < ActionDispatch::IntegrationTest
  setup do
    @repository = repositories(:one)
  end

  test "creates and runs repository check" do
    assert_difference -> { @repository.checks.count }, 1 do
      post api_checks_path,
           params: {
             repository: {
               full_name: @repository.full_name
             }
           },
           as: :json
    end

    assert_response :success

    check = @repository.checks.order(:created_at).last

    assert { check.finished? }
    assert { check.passed == true }
    assert { check.commit_id.present? }
    assert { check.output.present? }
  end
end
