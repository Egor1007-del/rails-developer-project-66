# frozen_string_literal: true

require "open3"

class RubocopLinter
  class Error < StandardError; end

  def call(repository_path:)
    stdout, stderr, status = Open3.capture3(
      {
        "BUNDLE_GEMFILE" => Rails.root.join("Gemfile").to_s
      },
      "bundle",
      "exec",
      "rubocop",
      "--config",
      Rails.root.join(".rubocop.yml").to_s,
      "--format",
      "json",
      ".",
      chdir: repository_path
    )

    raise Error, stderr if status.exitstatus > 1

    {
      passed: status.success?,
      output: stdout
    }
  end
end
