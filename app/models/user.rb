class User < ApplicationRecord
  has_many :repositories, dependent: :destroy, inverse_of: :user

  validates :provider, :uid, :email, :token, presence: true
  validates :email, uniqueness: true
  validates :uid, uniqueness: { scope: :provider }
end
