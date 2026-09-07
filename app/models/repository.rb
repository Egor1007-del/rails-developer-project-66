class Repository < ApplicationRecord
  extend Enumerize

  belongs_to :user, inverse_of: :repositories

  has_many :checks, dependent: :destroy, inverse_of: :repository

  has_one :latest_check,
        -> { order(created_at: :desc, id: :desc) },
        class_name: "Repository::Check"

  enumerize :language, in: %i[ruby javascript]

  validates :github_id, presence: true, uniqueness: { scope: :user_id }
end
