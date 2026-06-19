Rails.application.routes.draw do
  # devise 確認メールの再送機能を無効化する
  # 確認はメールアドレス変更時に行うが、失敗したら再度メアド変更を行えばよい
  # GET /users/confirmation/new, 確認画面
  # POST /users/confirmation 確認メール再送リクエスト
  not_found = ->(_env) { raise(ActionController::RoutingError, "Not Found") }
  get "users/confirmation/new", to: not_found
  post "users/confirmation", to: not_found

  # devise アカウントロック解除メールの再送機能を無効化する
  # ロック解除はメール内リンク (GET /users/unlock?unlock_token=...) または
  # unlock_in による時間経過で行う運用にしているため、再送 UI は提供しない
  # GET /users/unlock/new, 再送画面
  # POST /users/unlock, 再送リクエスト
  get "users/unlock/new", to: not_found
  post "users/unlock", to: not_found

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  devise_for :users,
             controllers: {
               registrations: "users/registrations", invitations: "users/invitations",
               confirmations: "users/confirmations"
             }
  root "sakes#index"
  resources :sakes do
    get :menu, on: :collection
    get :random, on: :collection
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up", to: "rails/health#show", as: :rails_health_check

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.application.config.x.letter_opener_enabled
end
