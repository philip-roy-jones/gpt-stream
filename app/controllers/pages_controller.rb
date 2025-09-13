class PagesController < ApplicationController
  def home
    @chat = Chat.new
    @chats = current_user.chats.order(updated_at: :desc)
  end
end