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

[aha-secret] allows you to store a secret message encrypted. Only the generated link can decrypt the message again. The message is encrypted by your browser and decrypted by the browser of the person who is allowed to read it. Secrets are deleted after the first reveal by default. Senders can instead allow repeated reveals for a retention time of up to one hour when sharing with a group. Reusable secrets remain available until the scheduled cleanup removes them after expiry. The server also automatically deletes unrevealed one-time messages after a maximum of seven days.


# Current Status

aha-secret is feature-complete; that is, it solves the problem it was created to solve.


# Features

* 100% Free Open Source Software ❤️
* End-to-end encryption
* One-Time-Secret.
* Optional short-lived reusable secrets
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

# Contributing

All contributions, translations, bug reports, bug fixes, documentation improvements, enhancements, and any ideas are welcome.

Before starting work on the aha-secret codebase, please check the [CONTRIBUTING guide]({{ 'contributing' | relative_url }})

----

[aha-secret]: https://github.com/aha-oida/aha-secret
[aha-cli]: https://github.com/aha-oida/ahasecret-cli
