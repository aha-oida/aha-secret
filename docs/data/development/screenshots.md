---
title: Automated screenshots
parent: Development
nav_order: 4
layout: default
---

# Manual CI screenshots

There is a dedicated GitHub Actions workflow with a **Run workflow** button:

- Open **Actions** → **Manual Screenshots**
- Click **Run workflow**
- Download the artifact `manual-screenshots-<run_id>`

The workflow runs a single end-to-end scenario and creates screenshots for:

- landing page
- created secret/share link page
- copy-link step
- reveal page (before and after reveal)

Local run:

`RUN_MANUAL_SCREENSHOTS=true bundle exec rspec spec/features/manual_screenshots_spec.rb`

Screenshots are written to `tmp/capybara`.

You can make screenshots in your tests with:

```rb
page.save_screenshot(File.join(Capybara.save_path, 'your-screenshot-filename.png'), full: true)
```

# Test screenshots

Screenshots are generated in two ways:

* On feature test failures (saved in `tmp/capybara`).
* Manually via the dedicated screenshot scenario (`spec/features/manual_screenshots_spec.rb`).

The manual screenshot scenario is excluded from normal test runs by default.
To run it locally:

* `RUN_MANUAL_SCREENSHOTS=true bundle exec rspec spec/features/manual_screenshots_spec.rb`

In CI, use the **Manual Screenshots** workflow (Run workflow button).