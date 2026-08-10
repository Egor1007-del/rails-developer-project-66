Rails.application.routes.draw do
  root "home#index"
  get "/auth/:provider/callback", to: "auth#callback"
  get "/auth/failure", to: "auth#failure"

  delete "/logout", to: "auth#logout", as: :logout


  if Rails.env.test?
    post "/test/session", to: "auth#test_session"
  end
end
