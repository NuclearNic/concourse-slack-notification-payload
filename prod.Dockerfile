FROM ruby:2.4.1-slim-stretch

LABEL version='$GIT_REF' \
      maintainer="dl_onesie@jumo.world" \
      name="auth" \
      owner="onesie" \
      description="User authentication Service."

ENV BUILD_DEPS build-essential
ENV GEM_DEPS libpq-dev
ENV DB_DEPS postgresql-client

RUN apt-get update && apt-get install --yes --no-install-recommends $BUILD_DEPS \
    && apt-get install --yes --no-install-recommends $GEM_DEPS \
    && apt-get install --yes --no-install-recommends $DB_DEPS

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . /app

RUN echo "[{\"text\":\"\",\"fallback\":\"Deployment failed\",\"callback_id\":\"deploy\",\"color\":\"#3AA3E3\",\"attachment_type\":\"default\",\"actions\": [{\"name\":\"deploy_staging\",\"text\":\"Deploy to Staging\",\"type\":\"button\",\"value\":\"jumo/auth-api:a9ff90d\"}]}]" >>  payload.json

EXPOSE 3000
CMD ./bin/start.sh
