FROM ruby:3.2
LABEL authors="Wolfgang Hotwagner"

ARG RACK_ENV=production

ENV RACK_ENV=$RACK_ENV

RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY . .

RUN bundle install

RUN bundle exec rake db:migrate
CMD ["bundle","exec","rerun","--","rackup","-o","0.0.0.0"]
