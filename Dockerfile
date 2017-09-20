FROM ruby:2.3
RUN mkdir /auth_ms
WORKDIR /auth_ms
ADD Gemfile /auth_ms/Gemfile
ADD Gemfile.lock /auth_ms/Gemfile.lock
RUN bundle install
ADD . /auth_ms
