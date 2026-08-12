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
  end

  def create
    @github_repository = github_client.repository(repository_params[:github_id])

    @repository = current_user.repositories.build(
      name: github_repository[:name],
      github_id: github_repository[:id],
      full_name: github_repository[:full_name],
      language: github_repository[:language],
      clone_url: github_repository[:clone_url],
      ssh_url: github_repository[:ssh_url]
    )

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
    @github_client ||= GithubClient.new(current_user.token)
  end

  def repository_params
    params.require(:repository).permit(:github_id)
  end
end
