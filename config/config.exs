import Config

# Nostrum configuration is now handled via bot_options in supervisor
# config :nostrum,
#   token: System.get_env("DISCORD_TOKEN"),
#   gateway_intents: [
#     :guilds,
#     :message_content,
#     :guild_messages
#   ]

config :fruitbot,
  bots: [
    [
      bot: Fruitbot.Twitch,
      user: "coach",
      pass: System.get_env("TWITCH_PASSWORD"),
      channels: ["#freedrull_"],
      mod_channels: [],
      debug: true
    ]
  ]

