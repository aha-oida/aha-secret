# frozen_string_literal: true

# Application Controller helper methods
module Helpers
  LANDING_HELP_CARDS = [
    {
      key: 'what_happens',
      theme_class: 'landing-help-card--info',
      icon_path: 'M9.813 15.904 9 18.75l-.813-2.846a4.5 4.5 0 0 0-3.09-3.09L2.25 12l2.846-.813' \
                 'a4.5 4.5 0 0 0 3.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 0 0 3.09 3.09L15.75 12' \
                 'l-2.846.813a4.5 4.5 0 0 0-3.09 3.09ZM18.259 8.715 18 9.75l-.259-1.035a3.375 ' \
                 '3.375 0 0 0-2.455-2.456L14.25 6l1.036-.259a3.375 3.375 0 0 0 2.455-2.456L18 ' \
                 '2.25l.259 1.035a3.375 3.375 0 0 0 2.456 2.456L21.75 6l-1.035.259a3.375 3.375 ' \
                 '0 0 0-2.456 2.456ZM16.894 20.567 16.5 21.75l-.394-1.183a2.25 2.25 0 0 0-1.423' \
                 '-1.423L13.5 18.75l1.183-.394a2.25 2.25 0 0 0 1.423-1.423l.394-1.183.394 1.183' \
                 'a2.25 2.25 0 0 0 1.423 1.423l1.183.394-1.183.394a2.25 2.25 0 0 0-1.423 1.423Z'
    },
    {
      key: 'share_link',
      theme_class: 'landing-help-card--share',
      icon_path: 'M13.5 6H5.25A2.25 2.25 0 0 0 3 8.25v10.5A2.25 2.25 0 0 0 5.25 21h10.5A2.25 ' \
                 '2.25 0 0 0 18 18.75V10.5m-7.5-4.5 10.5 10.5m0-10.5v10.5H10.5'
    },
    {
      key: 'additional_password',
      theme_class: 'landing-help-card--password',
      icon_path: 'M16.5 10.5V6.75a4.5 4.5 0 1 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25' \
                 '-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 ' \
                 '2.25 0 0 0 2.25 2.25Z'
    },
    {
      key: 'one_time_secret',
      theme_class: 'landing-help-card--time',
      icon_path: 'M12 6v6l4 2m5-2a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z'
    }
  ].freeze

  def bin_retrieval_url(bin)
    "#{request.base_url}/bins/#{bin.id}"
  end

  def t(*, **)
    I18n.t(*, **)
  end

  def l(*, **)
    I18n.l(*, **)
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
    require_relative '../../lib/aha_secret/version'

    default_content = "<p><a href=\"https://github.com/aha-oida/aha-secret.git\">aha-secret</a> #{t :open_source}</p>"

    # Prepare version string if display_version is explicitly set to true
    version_content = if AppConfig.respond_to?(:display_version) && AppConfig.display_version == true
                        "<p>Version: #{AhaSecret::VERSION}</p>"
                      else
                        ''
                      end

    return default_content + version_content unless custom

    # When custom footer replaces default, still append version if enabled
    return content + version_content if custom == 'replace'

    # When custom footer is appended to default
    "#{content} #{default_content}#{version_content}"
  end
end
