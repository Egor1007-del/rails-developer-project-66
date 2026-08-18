# frozen_string_literal: true

class BuildFromGithub
  include Import[:github_client]

  def call(user:, github_id:)
    client = github_client.new(user.token)
    github_repository = client.repository(github_id)

    user.repositories.build(
      name: github_repository[:name],
      github_id: github_repository[:id],
      full_name: github_repository[:full_name],
      language: github_repository[:language]&.downcase,
      clone_url: github_repository[:clone_url],
      ssh_url: github_repository[:ssh_url]
    )
  end
end
