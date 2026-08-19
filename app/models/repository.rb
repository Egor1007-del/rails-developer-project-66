class Repository < ApplicationRecord
  extend Enumerize

  belongs_to :user, inverse_of: :repositories

  has_many :checks, dependent: :destroy, inverse_of: :repository

  enumerize :language, in: %i[ruby]

  validates :name, presence: true
  validates :github_id, presence: true, uniqueness: { scope: :user_id }
  validates :full_name, presence: true
  validates :clone_url, presence: true
  validates :ssh_url, presence: true
end
