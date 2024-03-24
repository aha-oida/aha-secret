# frozen_string_literal: true

# Model for the Bin-Record
class Bin < ActiveRecord::Base
  validates :payload, presence: true, length: { maximum: 10_000 }
  has_secure_token :random_id
end
