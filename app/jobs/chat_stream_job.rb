class ChatStreamJob < SidekiqJob
  include ActionView::RecordIdentifier

  # Add uniqueness constraint based on message ID
  sidekiq_options unique: :until_executed, unique_args: ->(args) { [args[1]] }

  def perform(chat_id, message_id)
    @message = Message.find(message_id)

    # Skip if message already has content
    return if @message.content.present?

    @chat = Chat.find(chat_id)
    @user = @chat.user
    @buffer = ""
    @last_sent_position = 0
    @last_broadcast_time = Time.current

    # Set streaming flag
    @chat.update(is_streaming: true)

    # Update the UI to show cancel button
    Turbo::StreamsChannel.broadcast_replace_to(
      @user,
      target: "form_button_container",
      partial: "messages/form_button_container",
      locals: { form: nil, is_streaming: true }
    )

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

        # Set streaming flag back to false
        @chat.update(is_streaming: false)
        Rails.logger.info("[ChatStreamJob] starting for chat=#{@chat.id} message=#{@message.id} user=#{@user&.id} REDIS=#{ENV['REDIS_URL'] || 'default'}")

        # Update the UI to show send button
        Turbo::StreamsChannel.broadcast_replace_to(
          @user,
          target: "form_button_container",
          partial: "messages/form_button_container",
          locals: { form: nil, is_streaming: false }
        )
      end
    end
  end

  def broadcast_chunk
    chunk = @buffer[@last_sent_position..-1]
    return if chunk.blank?

    safe_broadcast_append(
      @user,
      target: "msg_#{@message.id}_chunks",
      partial: "messages/chunk",
      locals: { chunk: chunk },
      tag: "chunk"
    )

    @last_sent_position = @buffer.length
  end

  def broadcast_replace
    safe_broadcast_replace(
      @user,
      target: dom_id(@message),
      partial: "messages/message",
      locals: { message: @message },
      tag: "final_replace")
  end

  def safe_broadcast_append(record, target:, partial:, locals:, tag: nil)
    # Rails.logger.info("[ChatStreamJob] broadcast_append_to chat=#{record.id} target=#{target} tag=#{tag}")
    Turbo::StreamsChannel.broadcast_append_to(record, target: target, partial: partial, locals: locals)
  rescue => e
    Rails.logger.error("[ChatStreamJob] broadcast_append_to FAILED for chat=#{record.id} target=#{target} tag=#{tag} error=#{e.class}: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
  end

  def safe_broadcast_replace(record, target:, partial:, locals:, tag: nil)
    # Rails.logger.info("[ChatStreamJob] broadcast_replace_to chat=#{record.id} target=#{target} tag=#{tag}")
    Turbo::StreamsChannel.broadcast_replace_to(record, target: target, partial: partial, locals: locals)
  rescue => e
    Rails.logger.error("[ChatStreamJob] broadcast_replace_to FAILED for chat=#{record.id} target=#{target} tag=#{tag} error=#{e.class}: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
  end
end
