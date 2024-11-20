# frozen_string_literal: true

# Application Controller helper methods
module Helpers
  def bin_retrieval_url(bin)
    "#{request.base_url}/bins/#{bin.id}"
  end

  def t(*)
    I18n.t(*)
  end

  def l(*)
    I18n.l(*)
  end

  def html_title(custom:, content:)
    default_content = 'aha-secret: Share Secrets'
    return default_content unless custom

    return content if custom == 'replace'

    "#{content} | #{default_content}"
  end

  def html_meta_description(custom:, content:)
    default_content = 'AHA-Secret is a simple and secure way to share secrets.'
    return default_content unless custom

    return content if custom == 'replace'

    "#{content}, #{default_content}"
  end

  def html_meta_keywords(custom:, content:)
    default_content = 'secret, share, encryption, secure, simple, bin, paste, text, code'
    return default_content unless custom

    return content if custom == 'replace'

    "#{content}, #{default_content}"
  end

  def footer_content(custom:, content:)
    default_content = "<a href=\"https://github.com/aha-oida/aha-secret.git\">aha-secret</a> #{t :open_source}"
    return default_content unless custom

    return content if custom == 'replace'

    "#{content} #{default_content}"
  end
end
