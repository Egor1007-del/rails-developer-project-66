# frozen_string_literal: true

module Web
  module Repositories
    class ChecksController < Web::ApplicationController
      before_action :set_repository

      def show
        @check = @repository.checks.find(params[:id])
      end

      def create
        check = @repository.checks.create!

        RepositoryChecker.new.call(check)

        redirect_to repository_path(@repository)
      end

      private

      def set_repository
        @repository =
          current_user.repositories.find(params[:repository_id])
      end
    end
  end
end
