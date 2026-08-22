require "open3"

class EslintLinter
  class Error < StandardError; end

  def call(repository_path:)
    stdout, stderr, status = Open3.capture3(
      Rails.root.join("node_modules/.bin/eslint").to_s,
      "--no-config-lookup",
      "--config",
      Rails.root.join("eslint.config.mjs").to_s,
      "--format",
      "json",
      repository_path.to_s
    )

    raise Erorr, stderr if status.exitstatus > 1

    {
      passed: status.success?,
      output: stdout
    }
  end
end
