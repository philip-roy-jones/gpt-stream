class MessagesController < ApplicationController
  include ActionView::RecordIdentifier
  include ActionView::Helpers::TagHelper

  before_action :authenticate_user!

  def create
    new_chat = false

    # Create a new chat if needed, or use existing one
    @chat = if params[:chat_id].present?
              Chat.find(params[:chat_id])
    else
              # Auto-create chat with title from first message
              title = message_params[:content].truncate(40)
              new_chat = true
              Chat.create(user: current_user, title: title)
    end

    # Create user message
    @message = Message.create(message_params.merge(chat_id: @chat.id, role: "user"))

    # Create empty assistant message
    @assistant_message = @chat.messages.create(role: "assistant", content: "")

    # Start streaming in background
    ChatStreamJob.perform_async(@chat.id, @assistant_message.id)

    respond_to do |format|
      format.turbo_stream do
        if new_chat
          render turbo_stream: [
            turbo_stream.update("chat_container", partial: "chats/show", locals: { chat: @chat }),
            turbo_stream.append("js-container", content_tag(:div, "", data: { push_url: chat_path(@chat) }))
          ]
        else
          render turbo_stream: [
            turbo_stream.append("messages_list", partial: "messages/message", locals: { message: @message }),
            turbo_stream.append("messages_list", partial: "messages/message", locals: { message: @assistant_message })
          ]
        end
      end
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
