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
AHA_SECRET_BASE_URL=http://localhost
AHA_SECRET_SESSION_SECRET=your-secret
```

- For tests, `SKIP_SCHEDULER=true` is set automatically to avoid running background jobs.
- For CI, `CI=true` and other test-specific variables are set automatically.

> **Deprecated:** `MEMCACHE`, `SESSION_SECRET`, `APP_LOCALE`, `URL`, `PERMITTED_ORIGINS` (use the new `AHA_SECRET_*` variables instead).

For a full list of optional and advanced environment variables, see the [Complete Environment Variables Reference](/configuration/#complete-environment-variables-reference).

Now startup [aha-secret] using [docker-compose]:

```bash
docker compose up -d
```

You can finally access aha-secret locally with the url: `http://localhost:9292`.

{: .warning }
> This installation is just for demo. For production deployment it is highly recommended to use encryption and a reverse proxy. See the [reverse proxy example in the configuration documentation](/configuration/#reverse-proxy).

----

[docker]: https://docs.docker.com/engine/install/
[docker-compose]: https://docs.docker.com/engine/install
[aha-secret]: https://github.com/aha-oida/aha-secret
