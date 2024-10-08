---
title: Docker
parent: Installation
nav_order: 3
layout: default
---

# Docker

This page describes how to run [aha-secrets] with docker. However the built-in ratelimit function also
needs a memcache server running. Therefore it is recommended to use the [docker-compose]({% link docs/installation/docker-compose.md %}) 
instead.

## Build Container

It is not necessary to build a docker-image manually. The [github-registry](https://github.com/aha-oida/aha-secret/pkgs/container/aha-secret)
stores prebuilt images of [aha-secret]. However it is also possible to build it manually.
[aha-secret] ships with a [Dockerfile]. The following command will build the image:

```bash
$ docker build -t aha-secret .
```

## Run Application

*Please note that the following command will not persist any data and stored secrets will be deleted if the container is stopped*

```bash
$ docker run --rm -it aha-secret
```

In order to persist the database, use volumes:

```bash
$ docker run --rm -v ahadb:/usr/src/app/db/database aha-secret
```

----


[aha-secret]: https://github.com/aha-oida/aha-secret
[Dockerfile]: https://github.com/aha-oida/aha-secret/Dockerfile
[docker-image]: https://github.com/aha-oida/aha-secret/pkgs/container/aha-secret

