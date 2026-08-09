class User < ApplicationRecord
  validates :provider, :uid, :email, :token, presence: true
  validates :email, uniqueness: true
  validates :uid, uniqueness: { scope: :provider }
end
