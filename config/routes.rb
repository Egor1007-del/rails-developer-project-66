Rails.application.routes.draw do
  get "/auth/:provider/callback", to: "auth#callback"
  get "/auth/failure", to: "auth#failure"

  delete "/logout", to: "auth#logout", as: :logout
  scope module: :web do
    root "home#index"
    resources :repositories, only: [ :index, :show, :new, :create ]
  end


  if Rails.env.test?
    post "/test/session", to: "auth#test_session"
  end
end
