# frozen_string_literal: true

class Bin < ActiveRecord::Base
  validates :payload, presence: true, length: { maximum: 10_000 }
  has_secure_token :random_id
  self.primary_key = :random_id

  scope :expired, -> { where('expire_date < ?', Time.now) }

  def expired?
    expire_date < Time.now
  end

  def self.cleanup
    expired.destroy_all
  end
end
