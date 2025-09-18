class MessagesController < ApplicationController
  include ActionView::RecordIdentifier
  include ActionView::Helpers::TagHelper

  before_action :authenticate_user!

  def create
    # Create a new chat if needed, or use existing one
    @chat = if params[:chat_id].present?
              Chat.find(params[:chat_id])
            else
              # Auto-create chat with title from first message
              title = message_params[:content].truncate(40)
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
        render turbo_stream: [
          turbo_stream.update("chat_container", partial: "chats/chat", locals: { chat: @chat }),
          # Add a hidden field with the URL that we'll use with JavaScript
          turbo_stream.append("chat_container",
                              "<div id='url_updater' data-url='#{chat_path(@chat)}' style='display:none;'></div>".html_safe)
        ]
      end
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
