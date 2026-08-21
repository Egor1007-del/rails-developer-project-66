# frozen_string_literal: true

class RubocopLinterStub
  OUTPUT = JSON.generate(
    "files" => [],
    "summary" => {
      "offense_count" => 0
    }
  )

  def call(repository_path:)
    raise ArgumentError, "Repository path missing" if repository_path.blank?

    {
      passed: true,
      output: OUTPUT
    }
  end
end
