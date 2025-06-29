---

title: Security
permalink: /security/
nav_order: 5
layout: default
---

# Security

As the following dataflow diagram shows, aha-secret has a very minimalistic design with just two forms. One for encryption and the other for decryption.
A built-in ratelimit protects against misuse as a data storage and prevents enumeration or brute-force attacks. The developers try to minimize the
dependencies to keep the chances for supply-chain-attacks as low as possible.

![Threat-Model Diagram]({{ 'data/threat-model/tm-diagram.png' | relative_url}} "Dataflow diagram")

Please have a look at the [full aha-secrets threat-model]({{ 'data/threat-model/aha-model.pdf' | relative_url }}). It was made with [OWASP Threat Dragon].
Use [this link]({{ 'data/threat-model/aha-model.json' | relative_url }}) to download the config of the threat model.

## Environment Variables

The application is configured using environment variables. Use the new `AHA_SECRET_*` variables for all new deployments. Deprecated variables are supported for backward compatibility but should be avoided.

See the [Configuration](/configuration/) page for a complete list and details.

**Example:**

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

> **Deprecated:** `MEMCACHE`, `SESSION_SECRET`, `APP_LOCALE`, `URL`, `PERMITTED_ORIGINS` (use the new `AHA_SECRET_*` variables instead).

For secure deployment, environment variable reference, and advanced configuration, see the [Configuration documentation](/configuration/).

---

[OWASP Threat Dragon]: https://www.threatdragon.com
