module Web
  class RepositoriesController < ApplicationController
    before_action :authenticate_user!

    def index
      @pagy, @repositories = pagy(
        current_user.repositories
                    .includes(:latest_check)
                    .order(created_at: :desc),
        items: 10
      )
    end

    def new
      @repository = Repository.new
      @github_repositories = available_from_github.call(
        user: current_user
      )
    end

    def show
      set_repository
      @pagy, @checks = pagy(
        @repository.checks.order(created_at: :desc),
        items: 10
      )
    end

    def create
      @repository = current_user.repositories.find_or_initialize_by(github_id: repository_params[:github_id])

      if @repository.save
        RepositorySetupJob.perform_later(@repository.id)

        redirect_to repositories_path, notice: t(".success")

      else
        redirect_to repositories_path, alert: t(".failure")
      end
    end

    private

    def available_from_github
      @available_from_github ||= ::Repositories::AvailableFromGithub.new
    end

    def set_repository
      @repository = current_user.repositories.find(params[:id])
    end

    def repository_params
      params.require(:repository).permit(:github_id)
    end
  end
end
