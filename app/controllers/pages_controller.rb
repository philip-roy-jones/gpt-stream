class PagesController < ApplicationController
  # Only skip if the callback is actually defined to avoid ArgumentError
  if respond_to?(:skip_before_action) && _process_action_callbacks.any? { |cb| cb.filter == :authenticate_user! }
    skip_before_action :authenticate_user!, only: [:index]
  end
  def index
    # Redirect unauthenticated users to sign-in and clear any existing alert flash so first time users don't see it
    unless defined?(user_signed_in?) && user_signed_in?
      flash.discard(:alert) if flash.respond_to?(:discard)
      flash[:alert] = nil if flash.key?(:alert)
      redirect_to new_user_session_path and return
    end

    @chat = Chat.new
    @chats = current_user&.chats&.order(updated_at: :desc)
  end
end
