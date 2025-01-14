Rails.application.routes.draw do
  root "posts#index"

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

  get "mypage", to: "users#show", as: "mypage"
  get "mypage/likes", to: "users#likes", as: "mypage_likes"

  # begin 初期Routes --------------------------------------------------------------

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # end -------------------------------------------------------------------------------
end
