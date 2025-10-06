class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :chats

  before_validation :ensure_stream_token, on: :create

  private

  def ensure_stream_token
    return if stream_token.present?

    loop do
      self.stream_token = SecureRandom.uuid
      break unless User.exists?(stream_token: stream_token)
    end
  end
end
