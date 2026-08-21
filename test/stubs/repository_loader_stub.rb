# frozen_string_literal: true

class RepositoryLoaderStub
  PATH = Rails.root.join("test/fixtures/files/repository").to_s
  COMMIT_ID = "abc123"

  def call(_repository)
    {
      path: PATH,
      commit_id: COMMIT_ID
    }
  end

  def cleanup(_repository_path); end
end
