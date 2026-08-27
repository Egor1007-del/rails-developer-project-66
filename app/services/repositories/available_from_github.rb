module Repositories
  class AvailableFromGithub
    include Import["github_client"]

    def call(user:)
      Rails.cache.fetch(
        [ "available-github-repositories", user.cache_key_with_version ],
        expres_in: 5.minutes) do
        github_repositories = github_client
          .new(user.token)
          .repositories

        supported_languages = Repository.language.values.map(&:to_s)

        github_repositories.select do |github_repository|
          language = github_repository.language&.downcase

          supported_languages.include?(language)
        end
      end
    end
  end
end
