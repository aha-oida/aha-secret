# frozen_string_literal: true

require_relative '../config/binconf'
# A bin is the model that stores the encrypted secret.
# It has a payload, which is the encrypted secret, and a id, which is the unique identifier for the bin.
# Bins are only temporary and thrown away after expiry or reveal.
class Bin < Sequel::Model
  plugin :validation_helpers
  plugin :timestamps, update_on_create: true
  plugin :whitelist_security

  set_primary_key :id

  # Allow mass-assignment for has_password
  set_allowed_columns :payload, :has_password, :expire_date

  def validate
    super
    bin_conf = BinConf.instance
    validates_presence [:payload]
    validates_max_length bin_conf.calc_max_length, :payload
    return unless expire_date && expire_date > (Time.now.utc + 7 * 24 * 60 * 60)

    errors.add(:expire_date, "Can't be bigger than 7 days")
  end

  def expired?
    expire_date < Time.now.utc
  end

  def self.cleanup
    where { expire_date < Time.now.utc }.each(&:delete)
  end

  def password?
    !!self[:has_password]
  end
  alias_method :has_password?, :password?

  def self.expired
    where { expire_date < Time.now.utc }.all
  end

  def before_create
    super
    self.id ||= generate_unique_id
  end

  private

  def generate_unique_id
    require 'securerandom'
    loop do
      random_id = SecureRandom.urlsafe_base64(8).tr('-_', 'az')
      break random_id unless Bin[random_id]
    end
  end
end
