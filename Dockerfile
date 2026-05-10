# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.2.0
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# RAILS_LOG_TO_STDOUT is required for ECS — logs must go to stdout/stderr
# so the CloudWatch Logs agent can capture them from the container.
# SECRET_KEY_BASE must be injected at runtime via ECS task definition secrets
# (reference AWS Secrets Manager — never bake it into the image).
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    RAILS_LOG_TO_STDOUT="1"


# ── Build stage ────────────────────────────────────────────────────────────────
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY . .

RUN bundle exec bootsnap precompile app/ lib/


# ── Runtime stage ──────────────────────────────────────────────────────────────
FROM base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000
# Bind to 0.0.0.0 so ECS can route traffic through the task network interface.
# Migrations are NOT run here — execute `rails db:migrate` as a one-off ECS
# task in your CI/CD pipeline before deploying a new service revision.
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
