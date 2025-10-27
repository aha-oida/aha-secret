---
title: Environment
parent: Development
nav_order: 1
layout: default

---

## Run dev server

```bash
bundle install
overcommit --install
bundle exec rake db:migrate
bundle exec rake serve
# or: bundle exec rackup
# or: bundle exec rerun rackup
```

## See available rake tasks

```bash
bundle exec rake -T
```

## Create migration

```bash
bundle exec rake db:create_migration NAME=[migration_name]
```

## Run console

The shell script skips execution of Rufus Scheduler.

```bash
bin/console
```

## Run specs

### End-to-End (E2E) Test Requirements

To run the E2E (feature) tests locally, you must have a Chrome or Chromium browser installed and available in your system's PATH. The test suite uses Capybara with the Cuprite driver, which launches a real browser for JavaScript-enabled tests (headless in default mode, use `SHOW_BROWSER=1` to run feature tests with UI).

**CI runners** must also use an image that includes a Chrome or Chromium executable. If the browser is not available, E2E tests will fail to start.

If you encounter errors about missing browser executables, install Chrome/Chromium or update your CI image accordingly.

```bash
RACK_ENV=test bundle exec rake db:migrate
bundle exec rspec
# OR
bundle exec rake
```

Run e2e tests with request log output:
```
SHOW_BROWSER=1 bundle exec rake
```

## Environment Variables for Development and Testing

The application uses environment variables for configuration. For a full list of environment variables and advanced configuration, see the [Configuration documentation](/configuration/).


### Example `.env` for development

```bash
RACK_ENV=development
SKIP_SCHEDULER=true
```

- For tests, `SKIP_SCHEDULER=true` is set automatically to avoid running background jobs.
- For CI, `CI=true` and other test-specific variables are set automatically.


