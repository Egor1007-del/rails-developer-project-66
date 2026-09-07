class RepositorySetupJob < ApplicationJob
  queue_as :default

  def perform(repository_id)
    repository = Repository.find(repository_id)

    result = ::Repositories::BuildFromGithub.new.call(repository)

    unless result
      repository.destroy!
      return
    end

    ::InstallWebhook.new.call(
      user: repository.user,
      repository: repository
    )
  end
end
