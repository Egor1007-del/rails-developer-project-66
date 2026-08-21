# frozen_string_literal: true

require "open3"
require "tmpdir"
require "fileutils"

class RepositoryLoader
  class Error < StandardError; end

  def call(repository)
    repository_path = Dir.mktmpdir("repository-check-")

    clone(repository.clone_url, repository_path)

    {
      path: repository_path,
      commit_id: commit_id(repository_path)
    }
  rescue
    FileUtils.rm_rf(repository_path) if repository_path
    raise
  end

  def cleanup(repository_path)
    FileUtils.rm_rf(repository_path)
  end

  private

  def clone(clone_url, repository_path)
    _stdout, stderr, status = Open3.capture3(
      "git",
      "clone",
      "--depth",
      "1",
      clone_url,
      repository_path
    )
    raise Error, stderr unless status.success?
  end

  def commit_id(repository_path)
    stdout, stderr, status = Open3.capture3(
      "git",
      "-C",
      repository_path,
      "rev-parse",
      "HEAD"
    )

    raise Error, stderr unless status.success?

    stdout.strip
  end
end
