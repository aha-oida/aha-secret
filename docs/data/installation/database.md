---
title: Database
parent: Installation
nav_order: 2
layout: default
---

# Database

aha-secret uses SQLite 3 by default. PostgreSQL is available as an optional
backend for installations that already use or operate a PostgreSQL server.
Changing the database setting does not copy existing secrets from the old
database.

## SQLite

The normal bundle installs the SQLite adapter:

```bash
bundle install
bundle exec rake db:migrate
```

The development and test databases are stored below `db/database/`. In
production, persist `/usr/src/app/db/database` with a volume when running the
container:

```bash
docker run --rm -v ahadb:/usr/src/app/db/database aha-secret
```

## PostgreSQL

PostgreSQL is optional. The `pg` gem is therefore not part of the default
bundle, so SQLite-only installations do not install it.

Use the separate PostgreSQL bundle:

```bash
export BUNDLE_GEMFILE=Gemfile.postgresql
bundle install
```

The database must already exist. Its user must be able to connect and create or
alter tables while migrations run.

For example, a local PostgreSQL administrator can create a database owned by
the installation user:

```sql
CREATE USER aha_secret WITH PASSWORD 'change-me';
CREATE DATABASE aha_secret OWNER aha_secret;
```

Managed PostgreSQL services may require these steps through their web
interface instead.

### Connect to an existing server

`DATABASE_URL` is the recommended configuration method. It is read in all
environments and takes precedence over `config/database.yml`.

For a local PostgreSQL server using the current Unix/macOS user and a socket:

```bash
export DATABASE_URL='postgres:///aha_secret'
```

Choose `RACK_ENV` separately for the deployment: omit it for local development,
or set `RACK_ENV=production` when running the production environment.

To use explicit IPv4 localhost access:

```bash
export DATABASE_URL='postgres://aha_secret:password@127.0.0.1:5432/aha_secret'
```

To connect to a remote or managed server:

```bash
export DATABASE_URL='postgres://aha_secret:password@db.example.com:5432/aha_secret?sslmode=require'
```

Percent-encode reserved characters in the URL username or password. Store real
credentials in the deployment platform's secret store, not in source control.
Use the TLS options required by the PostgreSQL provider.

Apply the migrations and start aha-secret from the same shell:

```bash
export BUNDLE_GEMFILE=Gemfile.postgresql
bundle exec rake db:migrate
bundle exec rackup
```

Run `bundle exec rake db:migrate` after upgrades whenever migrations are
included.

### Individual connection variables

Instead of `DATABASE_URL`, production can also be configured with:

```bash
export DATABASE_ADAPTER=postgresql
export DATABASE_NAME=aha_secret
export DATABASE_USERNAME=aha_secret
export DATABASE_PASSWORD=change-me
export DATABASE_HOST=127.0.0.1
export DATABASE_PORT=5432
```

### Localhost and container networking

The database hostname is resolved from the machine or container running
aha-secret:

| Hostname | Use |
|----------|-----|
| `localhost` | Same host; may resolve through IPv6 `::1` or IPv4 `127.0.0.1` |
| `127.0.0.1` | Explicit IPv4 loopback address on the same host |
| `postgres` | A Docker Compose service named `postgres` |
| `host.docker.internal` | The container host in supported desktop Docker environments |
| `db.example.com` | A remote, managed, or otherwise network-accessible server |

Inside a container, `localhost` and `127.0.0.1` refer to that container, not
the Docker host or another container.

## PostgreSQL with Docker

The published default image contains the SQLite bundle and does not install
`pg`. Use a custom image when connecting a container to PostgreSQL.

For an existing PostgreSQL server, set both the alternate bundle and the
connection URL:

```Dockerfile
FROM ghcr.io/aha-oida/aha-secret:latest

ENV BUNDLE_GEMFILE=Gemfile.postgresql

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends libpq-dev \
    && bundle install \
    && apt-get purge -y --auto-remove libpq-dev \
    && rm -rf /var/lib/apt/lists/*
```

Build it and pass the connection URL at runtime:

```bash
docker build -t aha-secret-postgresql .
docker run --rm \
  -e RACK_ENV=production \
  -e DATABASE_URL='postgres://aha_secret:password@db.example.com:5432/aha_secret?sslmode=require' \
  aha-secret-postgresql
```

For Docker Compose, use the PostgreSQL service name instead of `localhost`:

```bash
DATABASE_URL=postgres://aha_secret:password@postgres:5432/aha_secret
```

No PostgreSQL container is required when the database already runs elsewhere.

## Development and tests

To develop or run the test suite with PostgreSQL, use separate databases:

```bash
createdb aha_secret_development
createdb aha_secret_test

BUNDLE_GEMFILE=Gemfile.postgresql \
DATABASE_URL=postgres:///aha_secret_development \
bundle exec rake db:migrate

BUNDLE_GEMFILE=Gemfile.postgresql \
DATABASE_URL=postgres:///aha_secret_test \
bundle exec rspec
```

The test suite cleans its configured database between examples. Do not point
tests at a database containing data you need to retain.
