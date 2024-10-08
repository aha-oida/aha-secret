# aha-secret

Sensitive information should not be stored in a mailbox or chat history.

aha-secret allows you to store a secret message encrypted. Only the generated
link could decrypt the message again. The message is encrypted by your
browser and decrypted by the browser of the person who is allowed to
read it. The first time someone clicks on the link, the message is automatically deleted from the server.

![Screenrecord of encryption and decryption](/docs/images/ahanimation.gif)

## Run dev server

```
bundle install
overcommit --install
bundle exec rake db:migrate
bundle exec rake serve
# or: bundle exec rackup
# or: bundle exec rerun rackup
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

Run application with german translation:

```
APP_LOCALE=de bundle exec rerun rackup
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
# OR
bundle exec rake
```

## Environment variables

The following environment variables can be used:

| Variable       | Description | Default |
|----------------|-------------|---------|
| URL            | Add url as origin | base-url |
| SESSION_SECRET | Set custom session-secret | random |
| MEMCACHE       | Set a memcache-server and enable rack-attack | empty(disable rack-attack) |
| APP_LOCALE     | Set the locale for the application | empty (default is en) |
| PLAYWRIGHT_HEADLESS | Run e2e tests with playwright headless |

## Docker-Compose

It is possible to start this application using docker-compose. It will not only start aha-secret but
also a memcache-service to the request-attempts for [Rack::Attack](https://github.com/rack/rack-attack).

The docker-compose-file uses the github-docker-repository to download the aha-secret docker-image. In order
to run aha-secret follow these instructions:


First download docker-compose:

```bash
$ wget https://raw.githubusercontent.com/aha-oida/aha-secret/main/docker-compose.yml
```

Next create a .env-file with the following content:

```
RACK_ENV=production
URL=https://please.change.me.now
MEMCACHE=memcached:11211
```

Finally start the containers:

```
docker-compose up -d
```


**Please note that this docker-compose file will not deploy a reverse-proxy. It is recommended to use a reverse proxy for production environments**


## Customizing the application

The application can be customized by changing the following files:

- 'config/config.yml' - set 'custom_stylesheet' to true
- 'public/custom.css' - add your custom css to this file

See the file 'public/application.css' for defined css classes you could simply overwrite.

You can even add your own logo by copying a logo to the 'public' folder and setting a background image in the 'public/custom.css' file.

Example:

```css
div#logo {
  width: 200px;
  height: 40px;
  background-image: url('logo.png');
  position: fixed;
  left:5px;
  top:5px;
  max-width:100%;
  background-repeat: no-repeat;
}
```
