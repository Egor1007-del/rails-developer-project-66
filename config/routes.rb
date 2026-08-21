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


  if Rails.env.test?
    post "/test/session", to: "web/auth#test_session"
  end
end
