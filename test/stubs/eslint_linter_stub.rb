# frozen_string_literal: true

class EslintLinterStub
  OUTPUT = JSON.generate(
    [
      {
        "filePath" => "/tmp/repository/app.js",
        "messages" => [
          {
            "ruleId" => "no-undef",
            "severity" => 2,
            "message" => "'userName' is not defined.",
            "line" => 2,
            "column" => 13
          }
        ],
        "errorCount" => 1,
        "warningCount" => 0
      }
    ]
  )

  def call(repository_path:)
    raise ArgumentError, "Repository path missing" if repository_path.blank?

    {
      passed: false,
      output: OUTPUT
    }
  end
end
