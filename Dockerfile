FROM ruby:2.5.3

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
          postgresql-client \
          nodejs \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile* /usr/src/app/
RUN bundle install --without development test

COPY . /usr/src/app

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
