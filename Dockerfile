FROM ruby:3.3
LABEL authors="Wolfgang Hotwagner"

RUN apt-get update

RUN apt-get install -y sqlite3

RUN apt-get clean

ARG RACK_ENV=production

ENV RACK_ENV=$RACK_ENV

RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY . .

RUN bundle install

CMD ["bundle","exec","rake","migrateserv"]
