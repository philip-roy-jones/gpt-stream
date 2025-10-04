class ChatsController < ApplicationController
  respond_to :html, :json

  before_action :authenticate_user!
  before_action :set_chat, only: %i[show]

  def new
    @chat = Chat.new

    respond_to do |format|
      format.html { render "pages/index" }
      format.turbo_stream do
        streams = [
          turbo_stream.update("chat_container", partial: "chats/new", locals: { chat: @chat })
        ]

        render turbo_stream: streams
      end
    end
  end

  def show
    respond_to do |format|
      format.html { render "pages/index" }
      format.turbo_stream do
        streams = [
          turbo_stream.update("chat_container", partial: "chats/show", locals: { chat: @chat })
        ]

        render turbo_stream: streams
      end
    end
  end

  private

  def set_chat
    @chat = current_user.chats.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to root_path, alert: 'Not authorized to access that chat.' }
      format.turbo_stream { head :forbidden }
      format.json { head :forbidden }
    end
  end

end
