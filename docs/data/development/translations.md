---
title: Translations
parent: Development
nav_order: 3
layout: default

---

# Add translations

If you want to add another language:


1. create a file in `/config/locales/[2-char-language_shortcode].yml`
1. fill in all defined locale variables in the new language (see existing language files for keys)
1. run `bundle exec i18n-tasks missing`
1. configure the new translation in `config/config.yml` (default_locale)
1. fork the repository and make a pull request
