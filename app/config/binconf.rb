# frozen_string_literal: true

class BinConf
  include Singleton
  attr_accessor :settings

  def set(setting, value)
    @settings ||= {}
    @settings[setting] = value
  end

  def calc_max_length
    unless @settings&.dig(:max_msg_length)
      @settings[:max_msg_length] = 10_000
    end

    if @settings[:max_msg_length] < 128
      256
    else
      @settings[:max_msg_length] * 2
    end
  end
end
