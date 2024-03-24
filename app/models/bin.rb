class Bin < ActiveRecord::Base
  validates :payload, presence: true
  before_create :generate_random_id

  def generate_random_id
    self.random_id = SecureRandom.hex(30)
  end
end
