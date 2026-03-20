#!/usr/bin/env ruby
# frozen_string_literal: true

require 'cgi'
require 'fileutils'

artifact_dir = File.expand_path(ARGV.fetch(0, 'tmp/capybara'))
artifact_name = ENV.fetch('AHA_SECRET_SCREENSHOT_ARTIFACT_NAME', nil)
run_url = [ENV.fetch('GITHUB_SERVER_URL', nil), ENV.fetch('GITHUB_REPOSITORY', nil), 'actions', 'runs',
           ENV.fetch('GITHUB_RUN_ID', nil)].compact.join('/')

FileUtils.mkdir_p(artifact_dir)

png_files = Dir.glob(File.join(artifact_dir, '*.png'))

summary_lines = [
  '## Screenshot Artifacts',
  ''
]

summary_lines << "Artifact: `#{artifact_name}`" if artifact_name && !artifact_name.empty?

if ENV.fetch('GITHUB_RUN_ID', nil) && ENV.fetch('GITHUB_REPOSITORY', nil) && ENV['GITHUB_SERVER_URL']
  summary_lines << "Run: #{run_url}"
end

summary_lines << ''

gallery_sections = []

if png_files.empty?
  summary_lines << 'No screenshots were generated in this job.'
else
  summary_lines << "Generated #{png_files.length} screenshot#{'s' unless png_files.length == 1}:"
  summary_lines << ''

  png_files.each do |png_path|
    png_name = File.basename(png_path)
    html_name = png_name.sub(/\.png\z/, '.html')
    html_path = File.join(artifact_dir, html_name)
    has_html = File.exist?(html_path)

    summary_lines << "- `#{png_name}`"
    summary_lines << "  - DOM snapshot: `#{html_name}`" if has_html

    gallery_sections << <<~HTML
      <section class="shot">
        <h2>#{CGI.escapeHTML(png_name)}</h2>
        <p><a href="./#{CGI.escapeHTML(png_name)}">Open PNG</a>#{" | <a href=\"./#{CGI.escapeHTML(html_name)}\">Open DOM snapshot</a>" if has_html}</p>
        <img src="./#{CGI.escapeHTML(png_name)}" alt="#{CGI.escapeHTML(png_name)}" loading="lazy">
      </section>
    HTML
  end
end

gallery_html = <<~HTML
  <!doctype html>
  <html lang="en">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>Screenshot Gallery</title>
      <style>
        body {
          background: #f5f1e8;
          color: #1f2937;
          font-family: "Iowan Old Style", "Palatino Linotype", serif;
          margin: 0;
          padding: 2rem;
        }
        h1 {
          font-size: 2rem;
          margin-bottom: 0.5rem;
        }
        p.meta {
          margin-top: 0;
          color: #4b5563;
        }
        .grid {
          display: grid;
          gap: 1.5rem;
        }
        .shot {
          background: rgba(255, 255, 255, 0.85);
          border: 1px solid #d6d3d1;
          border-radius: 16px;
          box-shadow: 0 10px 30px rgba(15, 23, 42, 0.08);
          padding: 1rem;
        }
        .shot h2 {
          font-size: 1rem;
          margin-top: 0;
          word-break: break-word;
        }
        .shot img {
          border-radius: 10px;
          display: block;
          height: auto;
          max-width: 100%;
        }
      </style>
    </head>
    <body>
      <h1>Screenshot Gallery</h1>
      <p class="meta">Artifact: #{CGI.escapeHTML(artifact_name.to_s)}</p>
      <div class="grid">
        #{gallery_sections.join("\n")}
      </div>
    </body>
  </html>
HTML

File.write(File.join(artifact_dir, 'index.html'), gallery_html)

puts summary_lines.join("\n")
