module Web
  class RepositoriesController < ApplicationController
    before_action :authenticate_user!

    def index
      @repositories = current_user.repositories
    end

    def new
      @repository = Repository.new
      @github_repositories = github_client.repositories
    end

    def show
      set_repository
      @checks = @repository.checks.order(created_at: :desc).limit(10)
    end

    def create
      @repository = BuildFromGithub.new.call(user: current_user, github_id: repository_params[:github_id])

      if @repository.save
        redirect_to repositories_path, notice: t(".success")
      else
        @github_repositories = github_client.repositories
        flash.now[:alert] = t(".failure")
        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_repository
      @repository = current_user.repositories.find(params[:id])
    end

    def github_client
      @github_client ||= ApplicationContainer[:github_client].new(current_user.token)
    end

    def repository_params
      params.require(:repository).permit(:github_id)
    end
  end
end
