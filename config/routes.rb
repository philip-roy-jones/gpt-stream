Rails.application.routes.draw do
  devise_for :users
  mount ActionCable.server => '/cable'

  # Standalone messages route for first message/chat creation
  resources :messages, only: [:create]

  # Nested messages for existing chats
  resources :chats, only: %i[show new] do
    resources :messages, only: %i[create]
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"
end
