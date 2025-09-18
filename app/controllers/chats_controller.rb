class ChatsController < ApplicationController
  respond_to :html, :json

  before_action :authenticate_user!
  before_action :set_chat, only: %i[show]

  def new
    @chat = Chat.new
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("chat_container", partial: "chats/new", locals: { chat: @chat }),
          # Add a hidden field with the URL that we'll use with JavaScript
          turbo_stream.append("chat_container",
                              "<div id='url_updater' data-url='#{new_chat_path(@chat)}' style='display:none;'></div>".html_safe)
        ]
      end
    end
  end

  def show
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("chat_container", partial: "chats/show", locals: { chat: @chat }),
          # Add a hidden field with the URL that we'll use with JavaScript
          turbo_stream.append("chat_container",
                              "<div id='url_updater' data-url='#{chat_path(@chat)}' style='display:none;'></div>".html_safe)
        ]
      end
    end
  end

  private

  def set_chat
    @chat = Chat.find(params[:id])
  end
end