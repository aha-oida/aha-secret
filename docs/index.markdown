---
title: About
nav_order: 1
description: "Documentation of the aha-secret project"
permalink: /
layout: default
---

# AHA-Secret Documentation
{: .fs-9 }

Encrypt your message, store it encrypted and share a link
{: .fs-6 .fw-300 }

[Get started now]({{ 'getting-started' | relative_url }}){: .btn .btn-primary .fs-5 .mb-4 .mb-md-0 .mr-2 }
[View it on GitHub][aha-secret]{: .btn .fs-5 .mb-4 .mb-md-0 }

---

Sensitive information should not be stored in a mailbox or chat history.
{: .fs-6 .fw-300 }

[aha-secret] allows you to store a secret message encrypted. Only the generated link could decrypt the message again. The message is encrypted by your browser and decrypted by the browser of the person who is allowed to read it. The first time someone clicks on the link, the message is automatically deleted from the server. After the secret was deleted from the server, the link does not work anymore. By using [aha-secret] users will only send weblinks to other users and those weblinks can only be used once. In addition to the one-time-secret, the server will also automatically delete unrevealed messages after a maximum of seven days.



# Features

* 100% Free Open Source Software ❤️
* End-to-end encryption
* One-Time-Secret.
* Self destruction
* No registration
* Ratelimit
* Command-Line Client in Rust: [aha-cli]
* Minimum Features / Dependencies

# Installation

Even if [aha-secret] can be installed [manually]({{ 'data/installation/manually' | relative_url }}) or by using [docker]({{ 'data/installation/docker' | relative_url }}) it is
recommended to use [docker-compose]({{ 'data/installation/docker-compose' | relative_url }}).
For installation instructions please read the [Getting started]({{ 'getting-started' | relative_url }}) or the [Installation section]({{ 'data/installation' | relative_url  }}). For customization
or all the configuration options read the section [Configuration]({{ '/configuration' | relative_url }}). For advanced configuration and all environment variables, see the [Configuration documentation]({{ '/configuration' | relative_url }}).

# Translations

[aha-secret] has translations for the following languages:

* German 🇩🇪
* English 🇬🇧

# License

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

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

----

[aha-secret]: https://github.com/aha-oida/aha-secret
[aha-cli]: https://github.com/aha-oida/ahasecret-cli
