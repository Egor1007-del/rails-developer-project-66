module Test
  class SessionsController < Web::ApplicationController
    def create
      email = params.require(:email)

      user = User.find_or_create_by!(email: email) do |new_user|
        new_user.provider = "test"
        new_user.uid = email
        new_user.nickname = email.split("@").first
        new_user.token = "test_token"
      end

      sign_in(user)

      head :ok
    end
  end
end
