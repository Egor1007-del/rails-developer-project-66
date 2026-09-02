module Web
  class AuthController < ApplicationController
    def callback
      auth = request.env.fetch("omniauth.auth")

      user = User.find_or_initialize_by(auth_params(auth))

      user.nickname = auth.dig("info", "nickname")
      user.name = auth.dig("info", "name")
      user.email = auth.dig("info", "email")
      user.image_url = auth.dig("info", "image")
      user.token = auth.dig("credentials", "token")

      user.save!

      sign_in(user)

      redirect_to root_path, notice: t(".success")
    end

    def failure
      redirect_to root_path, alert: t(".failure")
    end

    def logout
      sign_out
      redirect_to root_path, notice: t(".success")
    end

    def test_session
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

    private

    def auth_params(auth)
      {
        provider: auth["provider"],
        uid: auth["uid"]
      }
    end
  end
end
