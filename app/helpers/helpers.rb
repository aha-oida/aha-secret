# frozen_string_literal: true

# Application Controller helper methods
module Helpers
  def browser_locale(request)
    header = request&.env&.fetch('HTTP_ACCEPT_LANGUAGE', nil)
    return unless header

    available = I18n.available_locales.map(&:to_s)
    header.split(',').map { |lang| extract_locale_code(lang) }
          .compact
          .find { |locale_code| available.include?(locale_code) }
  end

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
    default_content = "<p><a href=\"https://github.com/aha-oida/aha-secret.git\">aha-secret</a> #{t :open_source}</p>"
    return default_content unless custom

    return content if custom == 'replace'

    "#{content} #{default_content}"
  end

  private

  def extract_locale_code(lang)
    code = lang[/^[a-zA-Z-]+/]
    code ? code.split('-').first.downcase : nil
  end
end
