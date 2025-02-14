class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_header
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def set_header
    if user_signed_in?
      @header_partial = "shared/after_header"
    else
      @header_partial = "shared/header"
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end
end
