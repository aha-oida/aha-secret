# frozen_string_literal: true

# A bin is the model that stores the encrypted secret.
# It has a payload, which is the encrypted secret, and a id, which is the unique identifier for the bin.
# Bins are only temporary and thrown away after expiry or reveal.
class Bin < ActiveRecord::Base
  class << self
    attr_accessor :max_msg_length
  end

  validates :payload, presence: true, length: { maximum: ->(_bin) { Bin.max_msg_length || 10_000 } }
  validate :expire_date_cannot_be_bigger_than_7_days
  has_secure_token :id
  self.primary_key = :id

  scope :expired, -> { where('expire_date < ?', Time.now.utc) }

  def expire_date_cannot_be_bigger_than_7_days
    return unless expire_date

    errors.add(:expire_date, "Can't be bigger than 7 days") if expire_date > Time.now.utc + 7.days
  end

  def expired?
    expire_date < Time.now.utc
  end

  def self.cleanup
    expired.in_batches do |batch|
      ActiveRecord::Base.transaction do
        batch.lock.delete_all
      end
    end
  end
end
