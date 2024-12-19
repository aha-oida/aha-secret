---
title: Environment
parent: Development
nav_order: 1
layout: default

---

## Run dev server

```bash
$ bundle install
$ overcommit --install
$ bundle exec rake db:migrate
$ bundle exec rake serve
# or: bundle exec rackup
# or: bundle exec rerun rackup
```

## See available rake tasks

```bash
$ bundle exec rake -T
```

## Create migration

```bash
$ bundle exec rake db:create_migration NAME=[migration_name]
```

## Run console

```bash
$ bin/console
```

## Run specs

```bash
$ RACK_ENV=test bundle exec rake db:migrate
$ bundle exec rspec
# OR
$ bundle exec rake
```
