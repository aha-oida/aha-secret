# frozen_string_literal: true

class Bin < ActiveRecord::Base
  validates :payload, presence: true, length: { maximum: 10_000 }
  validate :expire_date_cannot_be_bigger_than_7_days
  has_secure_token :random_id
  self.primary_key = :random_id

  scope :expired, -> { where('expire_date < ?', Time.now) }

  def expire_date_cannot_be_bigger_than_7_days
    if expire_date&. > (Date.today + 7.days)
      errors.add(:expire_date, "Can't be bigger than 7 days")
    end
  end

  def expired?
    expire_date < Time.now
  end

  def self.cleanup
    expired.destroy_all
  end
end
