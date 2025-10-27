---

title: Security
permalink: /security/
nav_order: 5
layout: default
---

# Security

As the following dataflow diagram shows, aha-secret has a very minimalistic design with just two forms. One for encryption and the other for decryption.
A built-in ratelimit protects against misuse as a data storage and prevents enumeration or brute-force attacks. The developers try to minimize the dependencies to keep the chances for supply-chain-attacks as low as possible.

![Threat-Model Diagram]({{ 'data/threat-model/tm-diagram.png' | relative_url}} "Dataflow diagram")

Please have a look at the [full aha-secrets threat-model]({{ 'data/threat-model/aha-model.pdf' | relative_url }}). It was made with [OWASP Threat Dragon].
Use [this link]({{ 'data/threat-model/aha-model.json' | relative_url }}) to download the config of the threat model.


---

[OWASP Threat Dragon]: https://www.threatdragon.com
