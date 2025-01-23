Rails.application.routes.draw do
  authenticated :user do
    root "posts#index", as: :authenticated_root
  end

  unauthenticated do
    root "tops#index", as: :unauthenticated_root
  end

  devise_for :users, controllers: {
    # passwords: "users/passwords",              #パスワード再設定用
    omniauth_callbacks: "omniauth_callbacks" # LINEログイン用
  }

  # 日付ごとのイベント詳細のルートを `resources :events` の外に定義
  get "events/dates/:date", to: "events#date_details", as: "event_date"

  resources :posts do
    resources :comments, only: %i[create edit update destroy]
    resources :likes, only: %i[create destroy]
  end

  resources :events

  post "/line_bot/callback", to: "line_bot#callback"

  get "mypage", to: "users#show", as: "mypage"
  get "mypage/likes", to: "users#likes", as: "mypage_likes"

  resources :contacts, only: [ :new, :create ]

  get "static_pages/privacy", to: "static_pages#privacy", as: "privacy"
  get "static_pages/terms", to: "static_pages#terms", as: "terms"
  # begin 初期Routes --------------------------------------------------------------

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # end -------------------------------------------------------------------------------
end
