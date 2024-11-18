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
    glibc-langpack-en \
    ImageMagick \
    && dnf clean all

# Configure locale to en_US.UTF-8
RUN localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    localectl set-locale LANG=en_US.UTF-8

# Set environment variables for the locale
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

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
