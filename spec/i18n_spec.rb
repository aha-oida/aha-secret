# frozen_string_literal: true

require_relative 'spec_helper'
require 'set'
require 'yaml'

RSpec.describe 'I18n locale consistency' do
  def locale_tree(file)
    data   = YAML.safe_load(File.read(file), aliases: true) || {}
    locale = data.keys.first.to_s
    [locale, data.fetch(locale, {})]
  end

  def flatten_tree(node, prefix = [], result = {})
    if node.is_a?(Hash)
      node.each { |key, value| flatten_tree(value, prefix + [key.to_s], result) }
    else
      result[prefix.join('.')] = node
    end
    result
  end

  def interpolation_vars(value)
    return Set.new unless value.is_a?(String)

    Set.new(value.scan(/%\{([^}]+)\}/).flatten)
  end

  let(:locale_files) { Dir[File.expand_path('../config/locales/*.yml', __dir__)].sort }
  let(:locale_data)  { locale_files.to_h { |file| locale_tree(file) } }
  let(:base_locale)  { 'en' }
  let(:base_tree)    { flatten_tree(locale_data.fetch(base_locale)) }

  it 'has all base locale keys in each locale file' do
    expect(locale_data).to have_key(base_locale)

    base_keys = base_tree.keys.to_set

    locale_data.each do |locale, tree|
      next if locale == base_locale

      locale_keys = flatten_tree(tree).keys.to_set
      missing     = (base_keys - locale_keys).to_a.sort

      expect(missing).to be_empty,
                        "Missing #{missing.count} keys in #{locale}:\n  #{missing.join("\n  ")}"
    end
  end

  it 'keeps interpolation placeholders consistent with base locale' do
    locale_data.each do |locale, tree|
      next if locale == base_locale

      flattened       = flatten_tree(tree)
      inconsistencies = []

      base_tree.each do |key, base_value|
        next unless flattened.key?(key)

        base_vars   = interpolation_vars(base_value)
        locale_vars = interpolation_vars(flattened[key])
        next if base_vars == locale_vars

        inconsistencies << "#{key} expected=#{base_vars.to_a.sort.inspect} actual=#{locale_vars.to_a.sort.inspect}"
      end

      expect(inconsistencies).to be_empty,
                                "Inconsistent interpolations in #{locale}:\n  #{inconsistencies.join("\n  ")}"
    end
  end
end