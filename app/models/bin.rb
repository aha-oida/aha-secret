# frozen_string_literal: true

# A bin is the model that stores the encrypted secret.
# It has a payload, which is the encrypted secret, and an id, which is the unique identifier for the bin.
# Bins are only temporary and thrown away after expiry or a one-time reveal.
class Bin < Sequel::Model
  plugin :validation_helpers
  plugin :timestamps, update_on_create: true
  plugin :defaults_setter # Use database defaults for columns

  # Set the primary key (custom ID)
  set_primary_key :id
  unrestrict_primary_key

  SEVEN_DAY_LIMIT_SECONDS = 7 * 24 * 60 * 60
  REUSABLE_DEFAULT_RETENTION_SECONDS = 15 * 60
  REUSABLE_RETENTION_LIMIT_SECONDS = 60 * 60

  # Validation
  def validate
    super
    validates_presence %i[payload expire_date]
    validates_max_length AppConfig.calc_max_length, :payload

    return unless expire_date && expire_date > maximum_expire_date

    errors.add(:expire_date, expire_date_error)
  end

  # Instance methods
  def expired?
    expire_date < Time.now.utc
  end

  def password?
    !!self[:has_password]
  end
  alias has_password? password?

  def reusable?
    !!self[:reusable]
  end

  # Dataset methods (class-level query methods)
  dataset_module do
    def expired
      where { expire_date < Time.now.utc }
    end

    def cleanup!
      # there are no callbacks on delete, so this is more efficient than calling destroy
      expired.delete
    end
  end

  # Hooks
  def before_validation
    super
    return if values.key?(:expire_date)

    retention = reusable? ? REUSABLE_DEFAULT_RETENTION_SECONDS : SEVEN_DAY_LIMIT_SECONDS
    self.expire_date = Time.now.utc + retention
  end

  def before_create
    super
    self.id ||= generate_unique_id
  end

  private

  def maximum_expire_date
    limit = reusable? ? REUSABLE_RETENTION_LIMIT_SECONDS : SEVEN_DAY_LIMIT_SECONDS
    Time.now.utc + limit
  end

  def expire_date_error
    reusable? ? "can't be bigger than 60 minutes for reusable secrets" : "can't be bigger than 7 days"
  end

  def generate_unique_id
    require 'securerandom'
    SecureRandom.uuid
  end
end
