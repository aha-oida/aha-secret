FROM ruby:4.0.2
LABEL authors="Wolfgang Hotwagner"

RUN apt-get update

RUN apt-get install -y sqlite3

RUN apt-get clean

ARG RACK_ENV=production

ENV RACK_ENV=$RACK_ENV

RUN bundle config --global frozen 1
RUN bundle config set --local without 'development test'

WORKDIR /usr/src/app

COPY . .

# Generate VERSION file from git before bundle install
RUN chmod +x scripts/addbuildid.sh && ./scripts/addbuildid.sh || true

RUN useradd -m -s /bin/bash appuser

RUN bundle install

RUN chown root.root -R *
RUN chown appuser.appuser -R db Gemfile.lock

USER appuser

CMD ["bundle","exec","rake","migrateserv"]
