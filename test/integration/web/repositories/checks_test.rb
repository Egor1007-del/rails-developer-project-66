require "test_helper"

class Web::Repositories::ChecksTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @repository = repositories(:one)
  end

  test "user creates repository check" do
    sign_in(@user)

    assert_difference -> { @repository.checks.count }, 1 do
      post repository_checks_path(@repository)
    end

    assert { response.redirect? }
    assert { response.location == repository_url(@repository) }

    check = @repository.checks.order(:created_at).last

    assert { check.present? }
    assert { check.created? }
  end

  private

  def sign_in(user)
    post "/test/session",
          params: {
            email: user.email
          }

    assert { response.successful? }
  end
end
