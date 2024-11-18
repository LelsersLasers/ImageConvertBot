# Use Fedora 40 as the base image
FROM fedora:40

# Install required dependencies (Erlang, Elixir, and other build tools)
RUN dnf update -y && \
    dnf install -y \
    git \
    gcc \
    make \
    curl \
    zlib-devel \
    openssl-devel \
    ncurses-devel \
    libtool \
    autoconf \
    erlang \
    elixir \
    ImageMagick \
    && dnf clean all

# Set the working directory in the container
WORKDIR /app

# Copy the mix project files
COPY mix.exs mix.lock ./

# Fetch dependencies
RUN mix local.hex --force && \
    mix deps.get

# Copy the rest of the project
COPY . .

RUN mix compile

ENV DISCORD_BOT_TOKEN="YOUR_BOT_TOKEN"

CMD ["mix", "run", "--no-halt"]
