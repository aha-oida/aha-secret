---
title: Manually
parent: Installation
nav_order: 1
layout: default
---

# Run aha-secret manually

First run a database-migration and then start the server:

```bash 
$ bundle exec rake db:migrate
$ bundle exec rerun rackup
```

Run application with german translation:

```bash
$ APP_LOCALE=de bundle exec rerun rackup
```

----


[aha-secret]: https://github.com/aha-oida/aha-secret
[Dockerfile]: https://github.com/aha-oida/aha-secret/Dockerfile
[docker-image]: https://github.com/aha-oida/aha-secret/pkgs/container/aha-secret

