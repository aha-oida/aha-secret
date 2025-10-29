# frozen_string_literal: true

# A bin is the model that stores the encrypted secret.
# It has a payload, which is the encrypted secret, and a id, which is the unique identifier for the bin.
# Bins are only temporary and thrown away after expiry or reveal.
class Bin < Sequel::Model
  plugin :validation_helpers
  plugin :timestamps, update_on_create: true
  plugin :whitelist_security
  plugin :defaults_setter  # Use database defaults for columns

  # Set the primary key (custom ID)
  set_primary_key :id
  unrestrict_primary_key

  # Allow mass-assignment for these columns
  set_allowed_columns :payload, :has_password, :expire_date

  # Validation
  def validate
    super
    validates_presence [:payload, :expire_date]
    validates_max_length AppConfig.calc_max_length, :payload
    
    # Validate expire_date is not more than 7 days in the future
    if expire_date && expire_date > (Time.now.utc + (7 * 24 * 60 * 60))
      errors.add(:expire_date, "can't be bigger than 7 days")
    end
  end

  # Instance methods
  def expired?
    expire_date < Time.now.utc
  end

  def password?
    !!self[:has_password]
  end
  alias has_password? password?

  # Class methods
  def self.cleanup
    where { expire_date < Time.now.utc }.delete
  end

  def self.expired
    where { expire_date < Time.now.utc }
  end

  # Hooks
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
