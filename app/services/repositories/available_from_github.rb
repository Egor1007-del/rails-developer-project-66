module Repositories
  class AvailableFromGithub
    include Import["github_client"]

    def call(user:)
      existing_github_ids = user.repositories.pluck(:github_id)

      Rails.cache.fetch(
        [ "available-github-repositories", user.cache_key_with_version,
          existing_github_ids.sort ],
        expires_in: 5.minutes) do
        github_repositories = github_client
          .new(user.token)
          .repositories

        supported_languages = Repository.language.values.map(&:to_s)

        github_repositories.select do |github_repository|
          language = github_repository.language&.downcase

          supported_languages.include?(language)&&
            existing_github_ids.exclude?(github_repository.id)
        end
      end
    end
  end
end
