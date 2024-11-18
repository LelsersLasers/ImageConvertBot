import Config

config :nostrum,
  token: "",
  gateway_intents: :all

config :logger, :console,
  metadata: [:shard, :guild, :channel]
