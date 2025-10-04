class ChatStreamJob < SidekiqJob
  include ActionView::RecordIdentifier

  # Add uniqueness constraint based on message ID
  sidekiq_options unique: :until_executed, unique_args: ->(args) { [args[1]] }

  def perform(chat_id, message_id)
    @message = Message.find(message_id)

    # Skip if message already has content
    return if @message.content.present?

    @chat = Chat.find(chat_id)
    @buffer = ""
    @last_sent_position = 0
    @last_broadcast_time = Time.current

    call_openai
  end

  private

  def call_openai
    OpenAI::Client.new.chat(
      parameters: {
        model: "gpt-4o-mini-2024-07-18",
        messages: Message.for_openai(@chat.messages.where.not(id: @message.id)),
        temperature: 0.8,
        stream: stream_proc
      }
    )
  end

  def stream_proc
    proc do |chunk, _bytesize|
      new_content = chunk.dig("choices", 0, "delta", "content")

      if new_content.present?
        @buffer += new_content

        # Broadcast chunks every ~100ms
        current_time = Time.current
        if current_time - @last_broadcast_time >= 0.1
          broadcast_chunk
          @last_broadcast_time = current_time
        end
      elsif chunk.dig("choices", 0, "finish_reason").present?
        # Final broadcast and persist
        broadcast_chunk if @last_sent_position < @buffer.length
        @message.update(content: @buffer)
        broadcast_replace
      end
    end
  end

  def broadcast_chunk
    chunk = @buffer[@last_sent_position..-1]
    return if chunk.blank?

    Turbo::StreamsChannel.broadcast_append_to(
      @chat,
      target: "msg_#{@message.id}_chunks",
      partial: "messages/chunk",
      locals: { chunk: chunk }
    )

    @last_sent_position = @buffer.length
  end

  def broadcast_replace
    Turbo::StreamsChannel.broadcast_replace_to(
      @chat,
      target: dom_id(@message),
      partial: "messages/message",
      locals: { message: @message }
    )
  end
end
