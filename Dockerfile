FROM ruby:2.4

RUN apt-get update && apt-get install -y build-essential curl

RUN mkdir /elastic_logger
WORKDIR /elastic_logger
ADD Gemfile /elastic_logger/Gemfile
ADD Gemfile.lock /elastic_logger/Gemfile.lock
RUN bundle install
ADD . /elastic_logger
CMD ruby app.rb
