defmodule Fruitbot.Commands do
  def handle_message(payload) do
    IO.inspect(payload)
    [command | tail] = String.split(payload)
    query = Enum.join(tail)

    case command do
      "!anysong" ->
        # pull a random link from #anysong channel in discord
        channel_id = 925232059058880522
        {:ok, msgs } = Nostrum.Api.get_channel_messages channel_id, 200
        msgs_with_urls = Enum.filter(Enum.map(msgs, fn m -> m.content end), fn m -> String.contains?(m, "https") end)
        urls = Enum.map(msgs_with_urls, fn s -> List.flatten(Regex.scan(~r/https.+/iu,  s)) end)
        msg = List.first(Enum.random(urls))
        {:ok, msg}
      "!vr" ->
        msg =
          "Join the party in VR here! https://hubs.mozilla.com/MsvfAkH/terrific-satisfied-area"

        {:ok, msg}

      "!donate" ->
        msg =
          "Enjoying the stream? The best way to support is with a monthly donation on ampled. https://www.ampled.com/artist/datafruits You can also make a one time donation to our paypal. https://paypal.me/datafruitsfm"

        {:ok, msg}

      # TODO would it be fun to have !advice randomly draw from the datafruits marquee or something? I mean I like the cheese cow advice but everytime
      "!advice" ->
        msg = "Don't live like me Brendon. Don't get a tattoo of a cheese cow."
        {:ok, msg}

      "!sorry" ->
        # shell to mplayer
        System.cmd("play", ["./sfx/onion_salad_dressing.mp3"])

        msg =
          "Must have been the onion salad dressing. Right, Brendon? :sorrymusthavebeentheonionsaladdressing:"

        {:ok, msg}

      "!thisisamazing" ->
        # shell to mplayer
        System.cmd("play", ["./sfx/thisisamazing.mp3"])
        msg = "It's just a website"
        {:ok, msg}

      "!gohackyourself" ->
        # shell to mplayer
        System.cmd("play", ["./sfx/go_hack_yourself.wav"])
        msg = "go hack yourself"
        {:ok, msg}

      "!next" ->
        next_show = Fruitbot.StreampusherApi.next_show()
        {:ok, next_show}

      "!wiki" ->
        wiki_link = Fruitbot.StreampusherApi.wiki_search(query)
        {:ok, wiki_link}

      "!tag" ->
        result = Fruitbot.StreampusherApi.tag_search(query)
        {:ok, result}

      "!datafruiter" ->
        result = Fruitbot.StreampusherApi.user_search(query)
        {:ok, result}

      "!commands" ->
        # can we pull the list of commands automatically somehow?
        msg = """
        !vr
        !donate
        !advice
        !sorry
        !thisisamazing
        !gohackyourself
        !next
        !wiki
        !tag
        !datafruiter
        !commands
        """
        {:ok, msg}

      _ ->
        IO.puts("unhandled command: #{command}")
        {:error}
    end
  end
end
