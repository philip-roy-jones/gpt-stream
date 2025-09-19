class ChatsController < ApplicationController
  respond_to :html, :json

  before_action :authenticate_user!
  before_action :set_chat, only: %i[show]

  def new
    @chat = Chat.new

    previous_chat_id = session[:selected_chat_id]

    session[:selected_chat_id] = nil

    respond_to do |format|
      format.turbo_stream do
        streams = [
          turbo_stream.update("chat_container", partial: "chats/new", locals: { chat: @chat }),
          # Add a hidden field with the URL that we'll use with JavaScript
          turbo_stream.append("chat_container",
                              "<div id='url_updater' data-url='#{root_path}' style='display:none;'></div>".html_safe)
        ]

        # Update previously selected chat if it exists
        if previous_chat_id.present?
          previous_chat = current_user.chats.find_by(id: previous_chat_id)
          streams << turbo_stream.replace("chat_item_#{previous_chat_id}",
                                          partial: "chats/chat_item",
                                          locals: { chat: previous_chat, selected: false }) if previous_chat
        end

        render turbo_stream: streams
      end
    end
  end

  def show
    previous_chat_id = session[:selected_chat_id]

    session[:selected_chat_id] = @chat.id

    respond_to do |format|
      format.html { render "pages/home" }
      format.turbo_stream do
        streams = [
          turbo_stream.update("chat_container", partial: "chats/show", locals: { chat: @chat }),
          # Update newly selected chat
          turbo_stream.replace("chat_item_#{@chat.id}",
                               partial: "chats/chat_item",
                               locals: { chat: @chat, selected: true }),
          # Add URL updater
          turbo_stream.append("chat_container",
                              "<div id='url_updater' data-url='#{chat_path(@chat)}' style='display:none;'></div>".html_safe)
        ]

        # Update previously selected chat if it exists and is different
        if previous_chat_id.present? && previous_chat_id != @chat.id
          previous_chat = current_user.chats.find_by(id: previous_chat_id)
          streams << turbo_stream.replace("chat_item_#{previous_chat_id}",
                                          partial: "chats/chat_item",
                                          locals: { chat: previous_chat, selected: false }) if previous_chat
        end

        render turbo_stream: streams
      end
    end
  end

  private

  def set_chat
    @chat = Chat.find(params[:id])
  end
end