class PagesController < ApplicationController
  before_action :authenticate_user!
  def index
    @chat = Chat.new
    @chats = current_user&.chats&.order(updated_at: :desc)
  end
end
