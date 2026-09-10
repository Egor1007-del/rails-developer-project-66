# frozen_string_literal: true

module Repositories
  class BuildFromGithub
    include Import[:github_client]

    def call(repository)
      client = github_client.new(repository.user.token)
      github_repository = client.repository(repository.github_id)

      repository.update!(
        name: github_repository.name,
        full_name: github_repository.full_name,
        language: github_repository.language&.downcase,
        clone_url: github_repository.clone_url,
        ssh_url: github_repository.ssh_url
      )

      repository
    end
  end
end
