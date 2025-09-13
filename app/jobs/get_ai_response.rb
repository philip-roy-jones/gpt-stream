class GetAiResponse < SidekiqJob
  RESPONSES_PER_MESSAGE = 1

  def perform(chat_id)
    chat = Chat.find(chat_id)
    call_openai(chat: chat)
  end

  private

  def call_openai(chat:)
    OpenAI::Client.new.chat(
      parameters: {
        model: "gpt-4o-mini-2024-07-18",
        messages: Message.for_openai(chat.messages),
        temperature: 0.8,
        stream: stream_proc(chat: chat),
        n: RESPONSES_PER_MESSAGE
      }
    )
  end

  def create_messages(chat:)
    messages = []
    RESPONSES_PER_MESSAGE.times do |i|
      message = chat.messages.create(role: "assistant", content: "", response_number: i)
      message.broadcast_created
      messages << message
    end
    messages
  end

  def stream_proc(chat:)
    puts "stream_proc for chat #{chat.id}"
    messages = create_messages(chat: chat)
    proc do |chunk, _bytesize|
      new_content = chunk.dig("choices", 0, "delta", "content")
      message = messages.find { |m| m.response_number == chunk.dig("choices", 0, "index") }
      if new_content.present?
        message.update(content: message.content + new_content)
      end
    end
  end
end