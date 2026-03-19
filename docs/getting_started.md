---
title: Getting started

nav_order: 2
description: "Documentation of the aha-secret project"
permalink: /getting-started
layout: default
---

# Getting started
{: .fs-9 }

Everything you need to know to get started and host aha-secret locally
{: .fs-6 .fw-300 }

---

Install [docker] and [docker-compose] first.
Next download the docker-compose file:

```bash
wget https://raw.githubusercontent.com/aha-oida/aha-secret/main/docker-compose.yml
```

Create the file `.env` with the following content (recommended for new setups):

```bash
AHA_SECRET_PERMITTED_ORIGINS=http://localhost
AHA_SECRET_SESSION_SECRET=your-secret
AHA_SECRET_MEMCACHE_URL=memcached:11211
```

## Minimal Configuration for Production

For a production deployment, ensure the following requirements are met:

- Serve the application via HTTPS (SSL/TLS). The WebCrypto API only works in secure contexts, except on `localhost`.
- Local development on localhost can run over HTTP without SSL.

| Variable | Purpose | Recommendation |
|----------|---------|----------------|
| `AHA_SECRET_SESSION_SECRET` | Secures session cookies | **Set to a long, random string** |
| `AHA_SECRET_RATE_LIMIT` | Requests per IP (default: 65) | Set based on your expected traffic |
| `AHA_SECRET_RATE_LIMIT_PERIOD` | Rate limit window in seconds (default: 60) | 60 is recommended |
| `AHA_SECRET_CLEANUP_SCHEDULE` | Background cleanup interval (default: 10m) | Adjust based on data volume |
| `AHA_SECRET_BASE_URL` | Application URL path (default: /) | Update if deployed at a subpath |
| `AHA_SECRET_PERMITTED_ORIGINS` | Allowed origins used by Rack::Protection | **Required in production (set to your domain)** |

> Most variables have sensible defaults, but for production you should explicitly configure `AHA_SECRET_PERMITTED_ORIGINS` and run behind HTTPS. See the [Complete Environment Variables Reference]({{ site.baseurl }}/configuration/#complete-environment-variables-reference) for all options.

- For tests, `SKIP_SCHEDULER=true` is set automatically to avoid running background jobs.
- For CI, `CI=true` and other test-specific variables are set automatically.

> Legacy variables `MEMCACHE`, `SESSION_SECRET`, `APP_LOCALE`, `URL`, and `PERMITTED_ORIGINS` are no longer supported and are ignored with a warning.

For a full list of optional and advanced environment variables, see the [Complete Environment Variables Reference]({{ site.baseurl }}/configuration/#complete-environment-variables-reference).

Now startup [aha-secret] using [docker-compose]:

```bash
docker compose up -d
```

You can finally access aha-secret locally with the url: `http://localhost:9292`.

{: .warning }
> This installation is just for demo. For production deployment you must use HTTPS (SSL/TLS), typically via a reverse proxy. See the [reverse proxy example in the configuration documentation]({{ site.baseurl }}/configuration/#reverse-proxy).

----

[docker]: https://docs.docker.com/engine/install/
[docker-compose]: https://docs.docker.com/engine/install
[aha-secret]: https://github.com/aha-oida/aha-secret
