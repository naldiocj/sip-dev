# syntax=docker/dockerfile:1
FROM ruby:3.4.10-slim AS base

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gcc \
    g++ \
    make \
    postgresql-client \
    libpq-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js and pnpm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g pnpm

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application files
COPY . .

# Install JavaScript dependencies
RUN pnpm install --frozen-lockfile

# Precompile assets
RUN RAILS_ENV=production bundle exec rails assets:precompile

# Production image
FROM base AS production

ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
