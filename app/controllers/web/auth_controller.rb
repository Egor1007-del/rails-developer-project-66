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

      if user.save
        sign_in(user)
        redirect_to root_path, notice: t(".success")
      else
        redirect_to root_path, alert: t(".failure")
      end
    end

    def failure
      redirect_to root_path, alert: t(".failure")
    end

    def logout
      sign_out
      redirect_to root_path, notice: t(".success")
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
