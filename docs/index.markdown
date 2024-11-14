---
title: About
layout: home
nav_order: 1
description: "Documentation of the aha-secret project"
permalink: /
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

Even if [aha-secret] can be installed [manually]({{ 'docs/installation/manually' | relative_url }}) or by using [docker]({{ 'docs/installation/docker' | relative_url }}) it is
recommended to use [docker-compose]({{ 'docs/installation/docker-compose' | relative_url }}).
For installation instructions please read the [Getting started]({{ 'getting-started' | relative_url }}) or the [Installation section]({{ 'docs/installation' | relative_url  }}). For customization
or all the configuration options read the section [Configuration]({{ '/configuration' | relative_url }}).

# Translations

[aha-secret] has translations for the following languages:

* German 🇩🇪
* English 🇬🇧

# License

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

----

[aha-secret]: https://github.com/aha-oida/aha-secret
[aha-cli]: https://github.com/aha-oida/ahasecret-cli
