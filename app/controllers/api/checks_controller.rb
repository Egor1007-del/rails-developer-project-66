module Api
  class ChecksController < ApplicationController
    skip_forgery_protection only: :create

    def create
      repository = Repository.find_by!(
        full_name: repository_params[:full_name]
      )

      check = repository.checks.create!

      RepositoryChecker.new.call(check)

      head :ok
    end

    private

    def repository_params
      params.require(:repository).permit(:full_name)
    end
  end
end
