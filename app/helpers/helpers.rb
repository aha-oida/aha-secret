# frozen_string_literal: true

# Application Controller helper methods
module Helpers
  def bin_retrieval_url(bin)
    "#{request.base_url}/bins/#{bin.id}"
  end

  # strip params to only: payload (text), password (boolean) and retention (integer)
  def reduce_params(params)
    # check bin's params
    params = reduce_bin_params(params[:bin]) if params[:bin]

    # check retention - which is given in seconds and converted to DateTime later
    params.delete(:retention) unless params[:retention]&.to_i&.positive?
    # check top level keys
    params.each_key do |key|
      params.delete(key) unless %w[bin retention].include?(key.to_s)
    end
    params
  end

  def reduce_bin_params(params)
    # check bin's params
    params.each_key do |key|
      params.delete(key) unless %w[payload password].include?(key.to_s)
    end
    params
  end
end
