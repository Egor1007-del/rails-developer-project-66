class RepositoryCheckJob < ApplicationJob
  queue_as :default

  def perform(check)
    RepositoryChecker.new.call(check)
  end
end
