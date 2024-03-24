class Bin < ActiveRecord::Base
  validates :payload, presence: true
  has_secure_token :random_id
end
