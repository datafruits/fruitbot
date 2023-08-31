import Config

config :nostrum,
  # The token of your bot as a string
  token: System.get_env("DISCORD_TOKEN")

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

