FROM ruby:3.2
LABEL authors="Wolfgang Hotwagner"

ARG RACK_ENV=production

ENV RACK_ENV=$RACK_ENV

RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY . .

RUN bundle install

CMD ["bundle","exec","rake","migrateserv"]
