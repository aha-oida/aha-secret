---
title: Home
layout: home
nav_order: 1
description: "Documentation of the aha-secret project"
permalink: /
---

# AHA-Secret Documentation
{: .fs-9 }

Encrypt your message, store it encrypted and share a link
{: .fs-6 .fw-300 }

[Get started now](#getting-started){: .btn .btn-primary .fs-5 .mb-4 .mb-md-0 .mr-2 }
[View it on GitHub][aha-secret]{: .btn .fs-5 .mb-4 .mb-md-0 }

---

Sensitive information should not be stored in a mailbox or chat history.
{: .fs-6 .fw-300 }

[aha-secret] allows you to store a secret message encrypted. Only the generated link could decrypt the message again. The message is encrypted by your browser and decrypted by the browser of the person who is allowed to read it. The first time someone clicks on the link, the message is automatically deleted from the server. After the secret was deleted from the server, the link does not work anymore. By using [aha-secret] users will only send weblinks to other users and those weblinks can only be used once.



# Features

* 100% Free Open Source Software ❤️
* End-to-end encryption
* One-Time-Secret. 
* Self destruction
* No registration
* Ratelimit
* Command-Line Client in Rust: [aha-cli]
* Minimum Features / Dependencies

# Translations

[aha-secret] has translations for the following languages:

* German 🇩🇪
* English 🇬🇧

# License

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

----

[aha-secret]: https://github.com/aha-oida/aha-secret
[aha-cli]: https://github.com/aha-oida/ahasecret-cli
