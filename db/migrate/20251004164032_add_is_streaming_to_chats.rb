class AddIsStreamingToChats < ActiveRecord::Migration[8.0]
  def change
    add_column :chats, :is_streaming, :boolean, default: false, null: false
  end
end
