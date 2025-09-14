---

title: Configuration
permalink: /configuration/
nav_order: 4
layout: default
---

# Configuration

It is possible to configure [aha-secret] by setting environment variables.

## Environment Variables

The application is configured using environment variables. Use the new AHA_SECRET_* variables for all new deployments. Deprecated variables are supported for backward compatibility but should be avoided.

The following environment variables can be set to configure the application:

| Variable       | Description | Default |
|----------------|-------------|---------|
| AHA_SECRET_BASE_URL | Set base-url of Website. (default: /) | base-url |
| AHA_SECRET_PERMITTED_ORIGINS | CORS/CSRF allowed origins | *(none)* | 
| AHA_SECRET_SESSION_SECRET | Set custom session-secret | random |
| AHA_SECRET_MEMCACHE_URL | Set a memcache-server and enable rack-attack | empty (disable rack-attack) |
| AHA_SECRET_APP_LOCALE | Set the locale for the application | empty (default is en) |

## Complete Environment Variables Reference

The following environment variables can be used to configure **aha-secret**. Most can be set in your shell, `.env` file, or via your deployment platform.

| Variable | Description | Default | Notes |
|----------|-------------|---------|-------|
| `AHA_SECRET_BASE_URL` | Set base-url of Website. (default: /) | `base-url` | |
| `AHA_SECRET_MEMCACHE_URL` | Memcache server URL for rate limiting and caching | *(none)* | Recommended. Enables Rack::Attack. Example: `localhost:11211` |
| `MEMCACHE` | (Deprecated) Old memcache server variable | *(none)* | Use `AHA_SECRET_MEMCACHE_URL` instead |
| `AHA_SECRET_SESSION_SECRET` | Secret for session encryption | Random | Set for production deployments |
| `SESSION_SECRET` | (Deprecated) Old session secret variable | Random | Use `AHA_SECRET_SESSION_SECRET` instead |
| `AHA_SECRET_CLEANUP_SCHEDULE` | Cron/interval for background cleanup | `10m` | Example: `1h`, `10m` |
| `AHA_SECRET_RATE_LIMIT` | Requests per period per IP | `64` | Used by Rack::Attack |
| `AHA_SECRET_RATE_LIMIT_PERIOD` | Rate limit period (seconds) | `60` | Used by Rack::Attack |
| `AHA_SECRET_DEFAULT_LOCALE` | Default locale | `en` | |
| `AHA_SECRET_MAX_MSG_LENGTH` | Max message length | `20000` | |
| `AHA_SECRET_PERMITTED_ORIGINS` | CORS/CSRF allowed origins | *(none)* | |
| `AHA_SECRET_APP_LOCALE` | Force app locale | `en` | |
| `APP_LOCALE` | (Deprecated) Old app locale variable | `en` | Use `AHA_SECRET_APP_LOCALE` instead |
| `RACK_ENV` | Rack environment | `development` | Use `production` for deployment, `test` for tests |
| `SKIP_SCHEDULER` | Disable background scheduler (Rufus) | *(none)* | Set to `true` in test/CI |
| `COVERAGE` | Enable code coverage (SimpleCov) | *(none)* | Used in test/CI |
| `CI` | Set automatically in CI | *(none)* | Used to enable CI-specific logic |
| `SHOW_BROWSER` | Show browser in e2e tests | *(none)* | Set to `true` to see browser window |
| `PLAYWRIGHT_BROWSER` | Browser for Playwright e2e tests | `chromium` | Can be `firefox`, `webkit` |
| `undercover_version` | Used in CI for coverage matrix | *(none)* | |

### Deprecated Environment Variables

- `MEMCACHE`, `SESSION_SECRET`, `APP_LOCALE`, `URL`, `PERMITTED_ORIGINS` are deprecated. Use the `AHA_SECRET_*` equivalents.
- Deprecated variables are still supported for backward compatibility but will show a warning.

### Precedence and Override Logic

- Environment variables override values in `config/config.yml`.
- If neither is set, built-in defaults are used.
- Deprecated ENV vars are mapped to new ones with a warning.

### Test/CI-Specific Variables

- `SKIP_SCHEDULER` is set to `true` in test/CI to disable background jobs.
- `COVERAGE`, `CI`, `SHOW_BROWSER`, `PLAYWRIGHT_BROWSER`, and `undercover_version` are used for test and CI configuration.

### Disabling Background Jobs

Set `SKIP_SCHEDULER=true` to prevent Rufus::Scheduler from running background jobs (e.g., in test or CI environments).

## Custom Style

The application can be customized by changing the following files:

- 'config/config.yml' - set 'custom_stylesheet' to true
- 'public/custom.css' - add your custom css to this file

See the file 'public/application.css' for defined css classes you could simply overwrite.

You can even add your own logo by copying a logo to the 'public' folder and setting a background image in the 'public/custom.css' file.

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
