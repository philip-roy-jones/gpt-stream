class Message < ApplicationRecord
  include ActionView::RecordIdentifier

  enum :role, { system: 0, assistant: 10, user: 20 }

  belongs_to :chat, touch: true

  after_create_commit -> { broadcast_created }
  after_update_commit -> { broadcast_updated }

  def broadcast_created
    broadcast_append_to(
      [ chat, :messages ],
      partial: "messages/message",
      locals: { message: self, scroll_to: true },
      target: dom_id(chat, :messages)
    )
  end

  def broadcast_updated
    broadcast_replace_to(
      [ chat, :messages ],
      target:  dom_id(self),
      partial: "messages/message",
      locals: { message: self, scroll_to: true },
    )
  end

  def self.for_openai(messages)
    messages.map { |message| { role: message.role, content: message.content } }
  end
end
