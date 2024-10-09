---
title: Getting started
layout: default
nav_order: 2
description: "Documentation of the aha-secret project"
permalink: /getting-started
---

# Getting started
{: .fs-9 }

Everything you need to know to get started and host aha-secret locally
{: .fs-6 .fw-300 }

---

Install [docker] and [docker-compose] first. 
Next download the docker-compose file:

```bash
$ wget https://raw.githubusercontent.com/aha-oida/aha-secret/main/docker-compose.yml
```

Create the file `.env` with the following content:

```bash
RACK_ENV=production
URL=http://localhost
MEMCACHE=memcached:11211
```

Now startup [aha-secret] using [docker-compose]:

```bash
$ docker compose up -d
```

You can finally access aha-secret locally with the url: `http://localhost:9292`.

{: .warning }
> This installation is just for demo. For production deployment it is highly recommended to use encryption and a reverse proxy.

----

[docker]: https://docs.docker.com/engine/install/
[docker-compose]: https://docs.docker.com/engine/install
[aha-secret]: https://github.com/aha-oida/aha-secret
