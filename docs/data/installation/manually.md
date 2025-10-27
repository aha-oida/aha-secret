---
title: Manually
parent: Installation
nav_order: 1
layout: default
---

## Manual Installation

This guide describes how to install [aha-secret] manually.
You will need a server and a dns entry for the server.

For manual installation we will install the following dependencies:

## Ruby

Install ruby e.g. with a version manager (asdf, chruby, rvm, rbenv)

See [.ruby-version](https://github.com/aha-oida/aha-secret/blob/main/.ruby-version) for the ruby version used in this project.

Ruby from the distribution package manager is not recommended, because it is often outdated.

## Reverse proxy software

E.g. nginx, apache, caddy

See [Configuration]({{ '/configuration' | relative_url }}) for an example nginx configuration.

## Aha-secret code

You don't need all the files in this repository for a deployment.
You could clone the repository in your home directory and then copy the files you need to your project directory.
Or let git do the work for you:

```bash
# in your home directory
git clone https://github.com/aha-oida/aha-secret.git

cd aha-secret

# let's assume you want to copy the files to /var/www/aha-secret/current
mkdir -p /var/www/aha-secret/current
git archive | /usr/bin/env tar -xf - -C  /var/www/aha-secret/current
```

## systemd service

Create a systemd service file for the aha-secret application.

```bash
# /etc/systemd/system/aha-secret.service
[Unit]
Description=Aha-secret service
Wants=nginx.service
# After=network.target nginx.service

[Service]
Type=simple
User=[your-username]
Group=[your-group]
WorkingDirectory=/var/www/aha-secret/current
ExecStart=/your/path/to/bundle exec puma -e production -d
Restart=always
TimeoutSec=10

[Install]
WantedBy=multi-user.target
```

## Configuration, Setup and Environment variables

# Run aha-secret manually

First install all dependencies:

```bash
bundle install
```

{: .note-title }
> SQLITE3 NEEDED
>
> Please make sure that sqlite3 is installed

Next run a database-migration:

```bash
bundle exec rake db:migrate
```

Run application with german translation:

```bash
APP_LOCALE=de bundle exec rerun rackup
```

----


[aha-secret]: https://github.com/aha-oida/aha-secret
[Dockerfile]: https://github.com/aha-oida/aha-secret/Dockerfile
[docker-image]: https://github.com/aha-oida/aha-secret/pkgs/container/aha-secret

