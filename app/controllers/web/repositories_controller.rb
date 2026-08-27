module Web
  class RepositoriesController < ApplicationController
    before_action :authenticate_user!

    def index
      @repositories = current_user.repositories.includes(:latest_check)
    end

    def new
      @repository = Repository.new
      @github_repositories = available_from_github.call(
        user: current_user
      )
    end

    def show
      set_repository
      @checks = @repository.checks.order(created_at: :desc).limit(10)
    end

    def create
      @repository = build_from_github.call(user: current_user, github_id: repository_params[:github_id])

      if @repository.save

        install_webhook.call(
          user: current_user,
          repository: @repository
        )

        redirect_to repositories_path, notice: t(".success")
      else
        @github_repositories = available_from_github.call(
          user: current_user
        )
        flash.now[:alert] = t(".failure")
        render :new, status: :unprocessable_entity
      end
    end

    private

    def build_from_github
      @build_from_github ||= ApplicationContainer[:build_from_github]
    end

    def available_from_github
      @available_from_github ||= ApplicationContainer[:available_from_github]
    end

    def install_webhook
      @install_webhook ||= ApplicationContainer[:install_webhook]
    end

    def set_repository
      @repository = current_user.repositories.find(params[:id])
    end

    def repository_params
      params.require(:repository).permit(:github_id)
    end
  end
end
