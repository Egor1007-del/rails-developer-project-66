Rails.application.routes.draw do
  root "home#index"
  get "/auth/:provider/callback", to: "auth#callback"
  get "/auth/failure", to: "auth#failure"

  delete "/logout", to: "auth#logout", as: :logout
end
