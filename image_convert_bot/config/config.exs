import Config

config :nostrum,
  token: "",
  gateway_intents: [:guilds, :guild_messages, :message_content],
  streamlink: nil,
  youtubedl: nil

config :logger, :console, metadata: [:shard, :guild, :channel]

config :logger, level: :debug
