module Stubs
  class GithubRepositoryStub
    def initialize(params)
      @params = params
    end

    def id
      @params[:id]
    end

    def name
      @params[:name]
    end

    def full_name
      @params[:full_name]
    end

    def language
      @params[:language]
    end

    def clone_url
      @params[:clone_url]
    end

    def ssh_url
      @params[:ssh_url]
    end
  end
end
