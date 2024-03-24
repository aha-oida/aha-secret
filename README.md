# aha-secret

## Run dev server

```
bundle install
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

## run specs

```
RACK_ENV=test bundle exec rake db:migrate 
bundle exec rspec
```
