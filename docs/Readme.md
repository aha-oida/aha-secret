This is the directory for aha-secrets documentation.

The documentation is built with [Jekyll](https://jekyllrb.com/) and hosted on [GitHub Pages](https://pages.github.com/).

## Environment Variables

The application is configured using environment variables. Use the new `AHA_SECRET_*` variables for all new deployments. Deprecated variables are supported for backward compatibility but should be avoided.

See the [Configuration](/configuration/) page for a complete list and details.

**Example:**

```env
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

> **Deprecated:** `MEMCACHE`, `SESSION_SECRET`, `APP_LOCALE`, `URL`, `PERMITTED_ORIGINS` (use the new `AHA_SECRET_*` variables instead).

For advanced configuration, see the [Configuration documentation](/configuration/).

For production deployment, see the [reverse proxy example in the configuration documentation](/configuration/#reverse-proxy).

---

## License

This project is licensed under the terms of the MIT License. See the [LICENSE](../../LICENSE) file for details.
