# frozen_string_literal: true

module Web
  class ApplicationController < ::ApplicationController
    allow_browser versions: :modern
    helper_method :current_user, :signed_in?

    private

    def current_user
      @current_user ||= User.find_by(id: session[:user_id])
    end

    def signed_in?
      current_user.present?
    end

    def authenticate_user!
      return if signed_in?

      redirect_to root_path, alert: t("auth.required")
    end
  end
end
