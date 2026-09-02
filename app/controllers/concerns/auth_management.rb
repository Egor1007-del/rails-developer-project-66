module AuthManagement
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :signed_in?
  end

  def sign_in(user)
    session[:user_id] = user.id
  end

  def sign_out
    reset_session
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def signed_in?
    current_user.present?
  end

  def authenticate_user!
    return if signed_in?

    redirect_to root_path, alert: t("authentication.required")
  end
end
