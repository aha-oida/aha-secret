# frozen_string_literal: true

# A bin is the model that stores the encrypted secret.
# It has a payload, which is the encrypted secret, and a id, which is the unique identifier for the bin.
# Bins are only temporary and thrown away after expiry or reveal.
class Bin < ActiveRecord::Base
  validates :payload, presence: true, length: { maximum: 10_000 }
  validate :expire_date_cannot_be_bigger_than_7_days
  has_secure_token :id
  self.primary_key = :id

  scope :expired, -> { where('expire_date < ?', Time.now) }

  def expire_date_cannot_be_bigger_than_7_days
    return unless expire_date

    errors.add(:expire_date, "Can't be bigger than 7 days") if expire_date > (Time.now + 7.days)
  end

  def expired?
    expire_date < Time.now
  end

  def self.cleanup
    # TODO: should be done in batches in background job
    ActiveRecord::Base.transaction do
      expired.lock.delete_all
    end
  end
end
