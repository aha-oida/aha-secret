# frozen_string_literal: true

# Application Controller helper methods
module Helpers
  def bin_retrieval_url(bin)
    "#{request.base_url}/bins/#{bin.id}"
  end
end
