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

  def rubocop_files
    parsed_output.fetch("files", [])
  end

  def offense_count
    parsed_output.dig("summary", "offence_count") || 0
  end

  private

  def parsed_output
    result { } if output.blank?

    JSON.parse(output)
  rescue JSON::ParserError
    {}
  end
end
