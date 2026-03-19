---

title: Configuration
permalink: /configuration/
nav_order: 4
layout: default
---

# Configuration

You can configure [aha-secret] using either environment variables or `config/config.yml`.
If both are provided, environment variables take precedence.

## Environment Variables

Environment variables are the preferred override mechanism. Use the `AHA_SECRET_*` variables.

## Configuration Tiers

The application requires different types of configuration:

### **Tier 1: System-Required Variables**
These 9 variables are essential for the application to function. All have sensible defaults defined in `config/config.yml`:
- `base_url`, `rate_limit`, `rate_limit_period`, `cleanup_schedule`, `default_locale`, `max_msg_length`, `session_secret`, `memcache_url`, and `custom`

**Impact if missing:** Application will fail to start.

### **Tier 2: Production-Required Security Setup**
These settings are required for a working production setup:
- HTTPS (SSL/TLS) — required because the browser WebCrypto API only works in secure contexts (except `localhost`)
- `permitted_origins` — required in production for Rack::Protection origin checks and bandwidth-limitation related protection behavior

**Impact if missing:** Encryption flows can fail in browsers (without HTTPS), and origin protection behavior is not configured as intended (without `permitted_origins`).

### **Tier 3: Production Best Practices**
These variables should be customized for production deployments:
- `session_secret` — Should be a long, random string (not a default)
- `rate_limit` and `rate_limit_period` — Tune to your traffic expectations
- `base_url` — Update if deployed at a non-root path
- `cleanup_schedule` — Adjust cleanup frequency based on data volume

**Impact if not customized:** Application runs with defaults, but may be insecure or inefficient.

### **Tier 4: Optional Features**
These variables enable specific features or customizations:
- `display_version` — Show version in footer
- `random_secret_*` — Random secret generation options
- `custom.*` — UI customization options

**Impact if missing:** Features are disabled or use defaults.

---

The following environment variables can be set to configure the application:

| Variable       | Description | Default |
|----------------|-------------|---------|
| AHA_SECRET_BASE_URL | Set base-url of Website.  | / |
| AHA_SECRET_PERMITTED_ORIGINS | CORS/CSRF allowed origins | *(none)* |
| AHA_SECRET_SESSION_SECRET | Set custom session-secret | random |
| AHA_SECRET_MEMCACHE_URL | Set a memcache-server and enable rack-attack | empty (disable rack-attack) |
| AHA_SECRET_APP_LOCALE | Set the locale for the application | *(none)* |

## Complete Environment Variables Reference

The following environment variables can be used to configure **aha-secret**. Most can be set in your shell, `.env` file, or via your deployment platform.

| Variable | Description | Default | Config.yml Key | Notes |
|----------|-------------|---------|----------------|-------|
| `AHA_SECRET_BASE_URL` | Set base-url of Website. | / | `base_url` | [REQUIRED] [RECOMMENDED] |
| `AHA_SECRET_MEMCACHE_URL` | Memcache server URL for rate limiting and caching | *(none)* | `memcache_url` | [REQUIRED] [RECOMMENDED] Enables Rack::Attack. Example: `localhost:11211` |
| `AHA_SECRET_SESSION_SECRET` | Secret for session encryption | Random | `session_secret` | [REQUIRED] [RECOMMENDED] Must be long, random string for production |
| `AHA_SECRET_CLEANUP_SCHEDULE` | Cron/interval for background cleanup | `10m` | `cleanup_schedule` | [REQUIRED] [RECOMMENDED] Example: `1h`, `5m` |
| `AHA_SECRET_RATE_LIMIT` | Requests per period per IP | `65` | `rate_limit` | [REQUIRED] [RECOMMENDED] Tune based on traffic. Used by Rack::Attack |
| `AHA_SECRET_RATE_LIMIT_PERIOD` | Rate limit period (seconds) | `60` | `rate_limit_period` | [REQUIRED] Used by Rack::Attack |
| `AHA_SECRET_DEFAULT_LOCALE` | Default locale | `en` | `default_locale` | [REQUIRED] |
| `AHA_SECRET_MAX_MSG_LENGTH` | Max message length | `20000` | `max_msg_length` | [REQUIRED] |
| `AHA_SECRET_DISPLAY_VERSION` | Display version in footer | `false` | `display_version` | [OPTIONAL] Set to `true` to show version |
| `AHA_SECRET_PERMITTED_ORIGINS` | CORS/CSRF allowed origins | *(none)* | `permitted_origins` | [REQUIRED FOR PRODUCTION] See [Permitted Origins documentation](#permitted-origins) |
| `AHA_SECRET_APP_LOCALE` | Force app locale | *(none)* | *(none)* | [OPTIONAL] Overrides default_locale when set |
| `RACK_ENV` | Rack environment | `development` | *(none)* | [RECOMMENDED] Use `production` for deployment, `test` for tests |
| `SKIP_SCHEDULER` | Disable background scheduler (Rufus) | *(none)* | *(none)* | [OPTIONAL] Set to `true` in test/CI |
| `COVERAGE` | Enable code coverage (SimpleCov) | *(none)* | *(none)* | [OPTIONAL] Used in test/CI |
| `CI` | Set automatically in CI | *(none)* | *(none)* | [OPTIONAL] Used to enable CI-specific logic |
| `SHOW_BROWSER` | Show browser in e2e tests | *(none)* | *(none)* | [OPTIONAL] Set to `true` to see browser window |
| `undercover_version` | Used in CI for coverage matrix | *(none)* | *(none)* | [OPTIONAL] |

### Removed Legacy Variables

- `MEMCACHE`, `SESSION_SECRET`, `APP_LOCALE`, `URL`, and `PERMITTED_ORIGINS` are no longer supported.
- If set, the application prints a deprecation warning and ignores them.

## Creating a config.yml File

The application can use a `config/config.yml` file for configuration instead of environment variables. This is useful for static deployments or when you prefer file-based configuration.

### Sample config.yml

```yaml
---
default: &common_settings
  rate_limit: 65
  rate_limit_period: 60  # in seconds
  cleanup_schedule: "10m"
  base_url: "/"
  default_locale: "en"
  max_msg_length: 20000
  session_secret: "your-secret-key-here"
  memcache_url: "localhost:11211"
  permitted_origins: "http://localhost"
  display_version: false  # Set to true to display version in footer
  custom:
    stylesheet: true
    html_title: false
    html_title_string: "Share secrets encrypted"
    meta_description: false
    meta_description_string: "Share secrets encrypted"
    meta_description_keywords: "Share, Secrets, Encrypted"
    footer: false
    footer_string: '<p>Custom footer <a href="https://example.com">link</a></p>'

development:
  <<: *common_settings
  session_secret: "dev-secret"
  memcache_url: ""
  permitted_origins: "http://localhost:9292"

production:
  <<: *common_settings
  session_secret: "CHANGE-THIS-TO-A-SECURE-RANDOM-STRING"
  memcache_url: "memcached:11211"
  permitted_origins: "http://localhost"
  display_version: false  # Don't display version in production for security

test:
  <<: *common_settings
  session_secret: "test-secret"
  memcache_url: ""
  permitted_origins: ""
  max_msg_length: 1000
```

### Configuration Notes

- **session_secret**: Should be a long, random string for production
- **memcache_url**: Leave empty to disable rate limiting, or set to your memcache server
- **display_version**: Shows application version in footer. Set to `false` in production for security
- **Environment-specific sections**: Override common settings per environment
- **custom**: Configure UI customization options

### HTTPS / SSL Requirement

For production, serve the application over HTTPS (SSL/TLS). The browser WebCrypto API requires a secure context and is only available on non-HTTPS origins for `localhost`.

Without HTTPS in production, client-side encryption/decryption flows will not work reliably.

#### Permitted Origins

`AHA_SECRET_PERMITTED_ORIGINS` controls which origins are allowed to access the application and protects against CORS and CSRF attacks.

**Format:** Comma-separated list of allowed origins, or leave empty/unset (default) to disable origin checking.

**Examples:**

```bash
# Single origin (typical for production)
AHA_SECRET_PERMITTED_ORIGINS=https://example.com

# Multiple origins
AHA_SECRET_PERMITTED_ORIGINS=https://example.com,https://www.example.com

# Local development
AHA_SECRET_PERMITTED_ORIGINS=http://localhost:9292,http://localhost:3000

# Wildcard (not recommended for production)
AHA_SECRET_PERMITTED_ORIGINS=*
```

In `config/config.yml`:

```yaml
permitted_origins: "https://example.com,https://www.example.com"
```

**Note:** For production, this value should be treated as required. Set it to your domain(s) so Rack::Protection origin checks and bandwidth-limitation related protection behavior are applied as intended.

### Precedence and Override Logic

- Environment variables override values in `config/config.yml`.
- If neither is set, built-in defaults are used.
- Legacy non-`AHA_SECRET_*` ENV vars are ignored with a warning.

### Test/CI-Specific Variables

- `SKIP_SCHEDULER` is set to `true` in test/CI to disable background jobs.
- `COVERAGE`, `CI`, `SHOW_BROWSER` and `undercover_version` are used for test and CI configuration.

### Disabling Background Jobs

Set `SKIP_SCHEDULER=true` to prevent Rufus::Scheduler from running background jobs (e.g., in test or CI environments).

## Custom Style

The application can be customized by changing the following files:

- 'config/config.yml' - set 'custom_stylesheet' to true
- 'public/stylesheets/custom.css' - add your custom CSS overrides here

See the file 'public/stylesheets/application.css' for defined css classes you could simply overwrite.

You can even add your own logo by copying a logo to the 'public' folder and setting a background image in the 'public/stylesheets/custom.css' file.

Example:

```css
div#logo {
  width: 200px;
  height: 40px;
  background-image: url('logo.png');
  position: fixed;
  left:5px;
  top:5px;
  max-width:100%;
  background-repeat: no-repeat;
}
```

## Reverse-Proxy

The following nginx-config example can be used for a reverse-proxy:

```
server {
	root /var/www/html;

	# Add index.php to the list if you are using PHP
	index index.html index.htm index.nginx-debian.html;
    server_name <YOUR_DOMAIN>;


	location / {
        # USE THE FOLLOWING HEADERS TO PROVIDE THE
        # REAL IP SO THAT RATELIMIT WORKS PROPERLY
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-For $remote_addr;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_pass http://127.0.0.1:9292;
	}

    listen [::]:443 ssl http2;
    listen *:443 ssl http2;
    ssl_certificate <PATH_TO_YOUR_CERTIFICATE>;
    ssl_certificate_key <PATH_TO_YOUR_PRIVATE_KEY>;
    ssl_dhparam <PATH_TO_YOUR_DHPARAMS>;

    # HSTS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
}
```
----

[aha-secret]: https://github.com/aha-oida/aha-secret
