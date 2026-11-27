# syntax=docker/dockerfile:1
# check=error=true

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=4.0.10
# Make sure NODE_VERSION matches the Node.js version in .node-version
ARG NODE_VERSION=22

# ============== node =================
FROM docker.io/library/node:${NODE_VERSION}-slim AS node

# ============== base =================
FROM docker.io/library/ruby:${RUBY_VERSION}-slim-trixie AS base

# hadolint ignore=DL3048
LABEL fly_launch_runtime="rails"

# Rails app lives here
WORKDIR /rails

# Update gems and bundler
RUN gem update --system --no-document && \
    gem install --no-document bundler:2.6.6

# Install base packages
RUN apt-get update --quiet && \
    apt-get install --no-install-recommends --yes \
    curl=8.* libjemalloc2=5.* libvips42t64=8.* postgresql-client-17=17.* && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# ============== build-base =================
# Throw-away build stage to reduce size of final image
FROM base AS build-base

SHELL ["/bin/bash", "-e", "-o", "pipefail", "-c"]

# Install packages needed to build gems and node modules
RUN apt-get update --quiet && \
    apt-get install --no-install-recommends --yes \
    build-essential=12.* libffi-dev=3.* libpq-dev=17.* libyaml-dev=0.2.* \
    node-gyp=11.* pkg-config=1.* python-is-python3=3.* && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install JavaScript dependencies
ARG YARN_VERSION=1.22.22
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    npm install --global yarn@$YARN_VERSION

# ============== build-production =================
FROM build-base AS build-production

# Set production environment
ENV BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    RAILS_ENV="production"

# Install application gems
COPY Gemfile Gemfile.lock .ruby-version ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Install node modules
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/releases/ ./.yarn/releases/
RUN yarn install --immutable

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile && \
    rm -rf node_modules

# ============== production =================
# Final stage for app image
FROM base AS production

# Set production environment
ENV BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    RAILS_ENV="production"

# Copy built artifacts: gems, application
COPY --from=build-production "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build-production /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown --recursive 1000:1000 db log storage tmp public
USER 1000:1000

# Entrypoint sets up the container.
ENTRYPOINT ["/rails/bin/fly.docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
ENV PORT="8080"
EXPOSE 8080

CMD ["./bin/rails", "server"]

# ============== development =================
# Final stage for development image
FROM build-base AS development

# Install application gems
COPY Gemfile Gemfile.lock .ruby-version ./
RUN bundle install && \
    gem install foreman:0.88.1 && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Install node modules
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/releases/ ./.yarn/releases/
RUN yarn install && yarn cache clean

# Install Playwright browsers and their system dependencies for system tests
# hadolint ignore=DL3060 # not yarn install
RUN yarn run playwright install --with-deps chromium && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy application code
COPY . .

# Entrypoint sets up the container.
ENTRYPOINT ["/rails/bin/dev.docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
ENV BINDING="0.0.0.0"
ENV PORT="3000"
EXPOSE 3000

CMD ["./bin/rails", "server"]
