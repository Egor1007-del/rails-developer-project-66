class Repository::Check < ApplicationRecord
  belongs_to :repository, inverse_of: :checks
end
