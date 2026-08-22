class Repository::Check < ApplicationRecord
  include AASM
  belongs_to :repository, inverse_of: :checks

  aasm column: :aasm_state do
    state :created, initial: true
    state :checking
    state :finished
    state :failed

    event :start do
      transitions from: :created, to: :checking
    end

    event :finish do
      transitions from: :checking, to: :finished
    end

    event :fail do
      transitions from: %i[created checking], to: :failed
    end
  end

  def files_with_offeses
    case repository.language.to_s
    when "ruby"
      rubocop_files
    when "javascript"
      eslint_files
    else
      []
    end
  end

  def offense_count
    case repository.language.to_s
    when "ruby"
        rubocop_offense_count
    when "javascript"
        eslint_offense_count
    else
        0
    end
  end

  private

  def rubocop_files
    parsed_result = parsed_output

    return [] unless parsed_result.is_a?(Hash)

    parsed_result
        .fetch("files", [])
        .select { |file| file.fetch("offenses", []).any? }
  end

  def eslint_files
    parsed_result = parsed_output

    return [] unless parsed_result.is_a?(Array)

    result.filter_map do |file|
      messages = file.fetch("messages", [])

      next if messages.empty?

      {
        "path" => file["filePath"],
        "offenses" => messages.map do |message|
          {
            "message" => message["message"],
            "cop_name" => message["ruleId"] || "ESLint",
            "location" => {
              "start_line" => message["line"],
              "start_column" => message["column"]
            }
          }
        end
      }
    end
  end

  def rubocop_offense_count
    result = parsed_output

    return 0 unless result.is_a?(Hash)

    result.dig("summary", "offense_count") || 0
  end

  def eslint_offense_count
    result = parsed_output

    return 0 unless result.is_a?(Array)

    result.sum do |file|
      file.fetch("messages", []).count
    end
  end

  def parsed_output
    return {} if output.blank?

    JSON.parse(output)
  rescue JSON::ParserError
    {}
  end
end
