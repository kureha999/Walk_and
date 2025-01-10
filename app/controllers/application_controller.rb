class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_header
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :require_login, unless: :devise_controller?

  private

  def require_login
    unless user_signed_in?
      redirect_to new_user_session_path, alert: "ログインが必要です。"
    end
  end

  def set_header
    if user_signed_in?
      @header_partial = "shared/after_header"
    else
      @header_partial = "shared/header"
    end
  end

  # Deviseのパラメータにnameを許可する
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end
end
