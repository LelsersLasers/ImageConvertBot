# Use the official Elixir image
FROM elixir:1.14

# Install dependencies for zlib and SSL
RUN apt-get update && apt-get install -y \
    build-essential libssl-dev zlib1g-dev

# Set the working directory
WORKDIR /app

# Copy the mix project files
COPY mix.exs mix.lock ./

# Fetch dependencies
RUN mix local.hex --force && \
    mix deps.get

# Copy the rest of the project
COPY . .

RUN mix compile

ENV DISCORD_BOT_TOKEN=""

CMD ["mix", "run", "--no-halt"]
