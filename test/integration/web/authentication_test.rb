require "test_helper"

class Web::AuthenticationTest < ActionDispatch::IntegrationTest
  test "guest sees sign in button only" do
    get root_path

    assert_response :success

    assert_select "button",
                  text: I18n.t("layouts.header.sign_in"),
                  count: 1

    assert_select "button",
                  text: I18n.t("layouts.header.sign_out"),
                  count: 0

    assert_select "a",
                  text: I18n.t("layouts.header.repositories"),
                  count: 0
  end
  test "test session creates and signs in user" do
    assert_difference("User.count", 1) do
      post "/test/session", params: { email: "test@example.com" }
    end

    assert_response :success

    get root_path

    assert_response :success
    assert_select "a",
                  text: I18n.t("layouts.header.repositories"),
                  count: 1
    assert_select "button",
                  text: I18n.t("layouts.header.sign_out"),
                  count: 1
    assert_select "button",
                  text: I18n.t("layouts.header.sign_in"),
                  count: 0
  end
  test "test session signs in existing user without creating duplicate" do
    user = users(:one)

    assert_no_difference("User.count") do
      post "/test/session", params: { email: user.email }
    end

    assert_response :success

    get root_path

    assert_response :success
    assert_select "a",
                  text: I18n.t("layouts.header.repositories"),
                  count: 1
    assert_select "button",
                  text: I18n.t("layouts.header.sign_out"),
                  count: 1
  end
  test "signed in user can sign out" do
    user = users(:one)

    post "/test/session", params: { email: user.email }
    assert_response :success

    delete logout_path

    assert_redirected_to root_path

    follow_redirect!

    assert_response :success

    assert_select "button",
                  text: I18n.t("layouts.header.sign_in"),
                  count: 1

    assert_select "button",
                  text: I18n.t("layouts.header.sign_out"),
                  count: 0

    assert_select "a",
                  text: I18n.t("layouts.header.repositories"),
                  count: 0
  end
end
