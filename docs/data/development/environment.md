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

To run the (feature) tests you need to have playwright installed.
Run
```bash
bin/playwright_setup
```
to install

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

The application uses environment variables for configuration. For development and testing, prefer the new `AHA_SECRET_*` variables. Deprecated variables are supported for backward compatibility but should be avoided in new setups.

### Commonly used variables

| Variable | Description | Default | Notes |
|----------|-------------|---------|-------|
| `AHA_SECRET_BASE_URL` | Base URL for the app (used as origin) | `http://localhost` | Replaces `URL` |
| `AHA_SECRET_SESSION_SECRET` | Session secret for encryption | random | Replaces `SESSION_SECRET` |
| `AHA_SECRET_MEMCACHE_URL` | Memcache server for rate limiting | *(none)* | Enables Rack::Attack, replaces `MEMCACHE` |
| `AHA_SECRET_APP_LOCALE` | Locale for the application | `en` | Replaces `APP_LOCALE` |
| `AHA_SECRET_CLEANUP_SCHEDULE` | Cleanup schedule for background jobs | `10m` | |
| `AHA_SECRET_RATE_LIMIT` | Requests per period per IP | `64` | Used by Rack::Attack |
| `AHA_SECRET_RATE_LIMIT_PERIOD` | Rate limit period (seconds) | `60` | Used by Rack::Attack |
| `AHA_SECRET_MAX_MSG_LENGTH` | Max message length | `20000` | |
| `AHA_SECRET_PERMITTED_ORIGINS` | CORS/CSRF allowed origins | *(none)* | |
| `RACK_ENV` | Rack environment | `development` | Use `test` for tests |
| `SKIP_SCHEDULER` | Disable background scheduler (Rufus) | *(none)* | Set to `true` in test/CI |
| `COVERAGE` | Enable code coverage (SimpleCov) | *(none)* | Used in test/CI |
| `CI` | Set automatically in CI | *(none)* | Used to enable CI-specific logic |
| `SHOW_BROWSER` | Show browser in e2e tests | *(none)* | Set to `true` to see browser window |
| `PLAYWRIGHT_BROWSER` | Browser for Playwright e2e tests | `chromium` | Can be `firefox`, `webkit` |
| `undercover_version` | Used in CI for coverage matrix | *(none)* | |

**Deprecated:** `MEMCACHE`, `SESSION_SECRET`, `APP_LOCALE`, `URL`, `PERMITTED_ORIGINS` (use the new `AHA_SECRET_*` variables instead).

### Example `.env` for development

```bash
AHA_SECRET_BASE_URL=http://localhost
AHA_SECRET_MEMCACHE_URL=localhost:11211
AHA_SECRET_SESSION_SECRET=your-secret
AHA_SECRET_APP_LOCALE=en
AHA_SECRET_CLEANUP_SCHEDULE=10m
AHA_SECRET_RATE_LIMIT=64
AHA_SECRET_RATE_LIMIT_PERIOD=60
AHA_SECRET_MAX_MSG_LENGTH=20000
SKIP_SCHEDULER=true
```

- For tests, `SKIP_SCHEDULER=true` is set automatically to avoid running background jobs.
- For CI, `CI=true` and other test-specific variables are set automatically.

### Overriding config

- Environment variables override values in `config/config.yml`.
- If neither is set, built-in defaults are used.
- Deprecated ENV vars are mapped to new ones with a warning.

For a full list of environment variables and advanced configuration, see the [Configuration documentation](/configuration/).