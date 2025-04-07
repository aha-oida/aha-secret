# frozen_string_literal: true

class BinConf
  include Singleton
  attr_accessor :settings

  def set(setting, value)
    @settings ||= {}
    @settings[setting] = value
  end
end
