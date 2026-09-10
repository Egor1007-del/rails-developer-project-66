class RepositorySetupJob < ApplicationJob
  queue_as :default

  def perform(repository_id)
    repository = Repository.find(repository_id)

    ::Repositories::BuildFromGithub.new.call(repository)

    ::InstallWebhook.new.call(
      user: repository.user,
      repository: repository
    )
  end
end
