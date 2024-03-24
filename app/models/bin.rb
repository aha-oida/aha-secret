class Bin < ActiveRecord::Base
  validates :payload, presence: true, length: { maximum: 10_000 }
  has_secure_token :random_id
end
