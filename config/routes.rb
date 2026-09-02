Rails.application.routes.draw do
  scope module: :web do
    get "/auth/:provider/callback", to: "auth#callback"
    get "/auth/failure", to: "auth#failure"

    delete "/logout", to: "auth#logout", as: :logout

    root "home#index"

    resources :repositories, only: [ :index, :show, :new, :create ] do
      resources :checks, only: [ :show, :create ], module: :repositories
    end
  end

  namespace :api do
    resources :checks, only: :create
  end
end
