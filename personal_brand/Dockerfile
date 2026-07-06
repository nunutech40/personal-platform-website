# syntax=docker/dockerfile:1

ARG ELIXIR_VERSION=1.16.3
ARG OTP_VERSION=26
ARG DEBIAN_VERSION=bookworm-slim

FROM elixir:${ELIXIR_VERSION}-otp-${OTP_VERSION}-slim AS build

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    ca-certificates \
    nodejs \
    npm \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV MIX_ENV=prod

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only prod
RUN mix deps.compile

COPY priv priv
COPY lib lib
COPY assets assets

RUN mix compile
RUN mix assets.deploy
RUN mix release

FROM debian:${DEBIAN_VERSION} AS app

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    openssl \
    libstdc++6 \
    ncurses-bin \
    ca-certificates \
    curl \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN useradd --system --create-home --home-dir /app personal_brand

ENV HOME=/app \
    MIX_ENV=prod \
    PHX_SERVER=true \
    ELIXIR_ERL_OPTIONS="+fnu" \
    PORT=4000

COPY --from=build --chown=personal_brand:personal_brand /app/_build/prod/rel/personal_brand ./
RUN mkdir -p /app/uploads && chown -R personal_brand:personal_brand /app

USER personal_brand

EXPOSE 4000
CMD ["/app/bin/personal_brand", "start"]
