Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV.fetch("GITHUB_CLIENT_ID", "mock_id"), ENV.fetch("GITHUB_CLIENT_SECRET", "mock_secret"), scope: "user:email"
end
