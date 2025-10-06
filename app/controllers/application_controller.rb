class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :ensure_guest_token

  helper_method :turbo_signed_stream_name_for_current_principal, :current_principal_stream_token

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  private

  def ensure_guest_token
    session[:guest_token] ||= SecureRandom.uuid
  end

  def current_principal_stream_token
    if user_signed_in?
      current_user.stream_token || (current_user.update!(stream_token: SecureRandom.uuid) && current_user.stream_token)
    else
      session[:guest_token]
    end
  end

  def turbo_signed_stream_name_for_current_principal
    Turbo::StreamsChannel.signed_stream_name(current_principal_stream_token)
  end
end
