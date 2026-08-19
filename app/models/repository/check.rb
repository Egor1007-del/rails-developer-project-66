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
end
