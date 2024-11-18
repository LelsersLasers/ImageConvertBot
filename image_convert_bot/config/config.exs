import Config

config :nostrum,
  token: "",
  gateway_intents: [:guilds, :guild_messages, :message_content]

config :logger, :console,
  metadata: [:shard, :guild, :channel]
