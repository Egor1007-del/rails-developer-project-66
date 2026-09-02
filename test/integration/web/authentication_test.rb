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
  test "github callback creates and signs in user" do
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      provider: "github",
      uid: "999999",
      info: {
        nickname: "new_user",
        name: "New User",
        email: "new@example.com",
        image: "image"
      },
      credentials: {
        token: "token"
      }
    )

    assert_difference("User.count", 1) do
      get "/auth/github/callback"
    end

    assert_redirected_to root_path

    follow_redirect!

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
  test "github callbackn signs in existing user without creating duplicate" do
    user = users(:one)

    assert_no_difference("User.count") do
      sign_in(user)
    end

    follow_redirect!

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

    sign_in(user)

    follow_redirect!

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
