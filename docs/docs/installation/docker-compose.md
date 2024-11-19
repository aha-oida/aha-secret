---
title: Docker-Compose
parent: Installation
nav_order: 3
layout: default
---

# Docker-Compose

The easiest way is to start this application using [docker-compose]. It will not only start [aha-secret] but also a memcache-service to the request-attempts for [Rack::Attack](https://github.com/rack/rack-attack). The docker-compose-file uses the github-docker-repository to download the [aha-secret] [docker-image]. In order to run aha-secret follow these instructions:

First download docker-compose:

```bash
$ wget https://raw.githubusercontent.com/aha-oida/aha-secret/main/docker-compose.yml
```

Next create a .env-file use setting for your installation:

```bash
RACK_ENV=production
URL=https://please.change.me.now
MEMCACHE=memcached:11211
```

Finally start the containers:

```bash
$ docker-compose up -d
```

{: .warning }
> Please note that this docker-compose file will not deploy a reverse-proxy. It is recommended to use a reverse proxy for production environments.

# Custom configs

In order to use a custom configfile or a custom css the docker-compose.yml needs volumes for that:

```yaml
services:
  ahasecret:
    #    build: .
    image: ghcr.io/aha-oida/aha-secret:latest
    volumes:
      - ahadb:/usr/src/app/db/database
      - ./config.yml:/usr/src/app/config/config.yml
      - ./custom.css:/usr/src/app/public/stylesheets/custom.css
    ports:
      - "9292:9292"
    #  environment:
       #      RACK_ENV: production
       #      # URL: "https://please.change.me.now"
       #      MEMCACHE: "memcached:11211"
    env_file: .env
    depends_on:
      - memcached

  memcached:
    image: "memcached:latest"

volumes:
  ahadb:
```

This config allows to have a local config.yml and custom.css and mount it into the docker-containers.

----


[aha-secret]: https://github.com/aha-oida/aha-secret
[docker-compose]: https://docs.docker.com/compose/
[docker-image]: https://github.com/aha-oida/aha-secret/pkgs/container/aha-secret

