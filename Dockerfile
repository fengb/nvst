FROM ruby:2.5.3-alpine as builder

RUN apk add --no-cache --update \
          bash \
          build-base \
          postgresql-client \
          postgresql-dev \
          nodejs \
          yarn \
          tzdata

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile* /usr/src/app/
RUN bundle install --without development test

COPY . /usr/src/app

RUN rails assets:precompile RAILS_ENV=production SECRET_KEY_BASE=fake DATABASE_URL=fake

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]

# --==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--

FROM ruby:2.5.3-alpine

RUN apk add --no-cache --update \
          postgresql-client \
          tzdata

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /usr/src/app /usr/src/app

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
