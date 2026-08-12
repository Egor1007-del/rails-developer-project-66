class GithubClient
  def initialize(token)
    @client = Octokit::Client.new(
      access_token: token,
      per_page: 100
    )

    @client.auto_paginate = true
  end

  def repositories
    @client.repos
  end
end
