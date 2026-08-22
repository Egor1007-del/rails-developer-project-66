# frozen_string_literal: true

class EslintLinterStub
  OUTPUT = JSON.generate([])

  def call(repository_path:)
    raise ArgumentError, "Repository path missing" if repository_path.blank?

    {
      passed: true,
      output: OUTPUT
    }
  end
end
