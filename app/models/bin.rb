# frozen_string_literal: true

# Model for the Bin-Record
class Bin < ActiveRecord::Base
  validates :payload, presence: true
end
