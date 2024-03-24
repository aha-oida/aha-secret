class Bin < ActiveRecord::Base
  validates :payload, presence: true

end
