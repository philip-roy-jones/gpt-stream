class ChatsController < ApplicationController
  respond_to :html

  before_action :authenticate_user!
  before_action :set_chat, only: %i[show]

  # Only skip if the callback is actually defined to avoid ArgumentError
  if respond_to?(:skip_before_action) && _process_action_callbacks.any? { |cb| cb.filter == :authenticate_user! }
    skip_before_action :authenticate_user!, only: [ :new ]
  end

  def new
    # Redirect unauthenticated users to sign-in and clear any existing alert flash so first time users don't see it
    unless defined?(user_signed_in?) && user_signed_in?
      flash.discard(:alert) if flash.respond_to?(:discard)
      flash[:alert] = nil if flash.key?(:alert)
      redirect_to new_user_session_path and return
    end

    @chat = Chat.new
  end

  def show
    respond_to do |format|
      format.html do
        render :show
      end
    end
  end

  private

  def set_chat
    @chat = current_user.chats.find(params[:id])
    @chats = current_user&.chats&.order(updated_at: :desc)
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to root_path, alert: 'Not authorized to access that chat.' }
      format.turbo_stream { head :forbidden }
      format.json { head :forbidden }
    end
  end

end
