# aha-secret

## Run dev server

```
bundle install
overcommit --install
bundle exec rake db:migrate
bundle exec rake serve
# or: bundle exec rackup
```

## See available rake tasks

```
bundle exec rake -T
```

## Create migration

```
bundle exec rake db:create_migration NAME=[migration_name]
```

## Run application

```
bundle exec rake db:migrate
bundle exec rerun rackup
```

## Run console

```
bin/console
```

## Docker

### Build Container

```
docker build -t aha-secret .
```

### Run Application

*Please note that the following command will not persist any data and stored secrets will be deleted if the container is stopped*

```
docker run --rm -it aha-secret
```

## run specs

```
RACK_ENV=test bundle exec rake db:migrate
bundle exec rspec
```
