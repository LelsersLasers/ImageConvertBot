import Config

config :nostrum,
  token: "666",
  gateway_intents: [:guilds, :guild_messages, :message_content],
  youtubedl: nil,
  ffmpeg: nil

config :logger, :console,
  metadata: [:shard, :guild, :channel]
