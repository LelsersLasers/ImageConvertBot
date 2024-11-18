import Config

config :nostrum,
  token: System.get_env("DISCORD_BOT_TOKEN"),
  gateway_intents: [:guilds, :guild_messages, :message_content],
  streamlink: nil,
  youtubedl: nil

config :logger, :console, metadata: [:shard, :guild, :channel]

config :logger, level: :debug
