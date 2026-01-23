FROM ruby:4.0.1
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

RUN bundle install

CMD ["bundle","exec","rake","migrateserv"]
