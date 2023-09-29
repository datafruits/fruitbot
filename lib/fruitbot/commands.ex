defmodule Fruitbot.Commands do
  def handle_message(payload) do
    IO.inspect(payload)
    [command | tail] = String.split(payload)
    query = Enum.join(tail)

    case command do
      "!anysong" ->
        # pull a random link from #anysong channel in discord
        channel_id = 925_232_059_058_880_522
        {:ok, msgs} = Nostrum.Api.get_channel_messages(channel_id, 200)

        urls =
          msgs
          |> Enum.map(fn m -> m.content end)
          |> Enum.filter(fn m -> String.contains?(m, "https") end)
          |> Enum.map(fn s -> List.flatten(Regex.scan(~r/https\S+/iu, s)) end)
          |> Enum.reject(fn each -> Enum.empty?(each) end)

        msg = List.first(Enum.random(urls))
        {:ok, msg}

      "!vr" ->
        msg =
          "Join the party in VR here! https://hubs.mozilla.com/MsvfAkH/terrific-satisfied-area"

        {:ok, msg}

      "!discord" ->
        msg = "https://discord.gg/kM3bW7SM"
        {:ok, msg}

      "!donate" ->
        msg =
          "Enjoying the stream? The best way to support is with a monthly donation on Patreon. https://patreon.com/datafruits You can also make a one time donation to our paypal. https://paypal.me/datafruitsfm"

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

      "!pewpew" ->
        # shell to mplayer
        System.cmd("play", ["./sfx/PEWPEW.wav"])
        msg = "pewpew"
        {:ok, msg}

      "!bass" ->
        # shell to mplayer
        System.cmd("play", ["./sfx/bass.mp3"])
        msg = "BASS"
        {:ok, msg}
        
      "!scream" ->
        # shell to mplayer
        System.cmd("play", ["./sfx/somebody_scream.wav"])
        msg = "c'mon ethel let's get outta here"
        {:ok, msg}

      "!internet" ->
        # shell to mplayer
        System.cmd("play", ["./sfx/internet.wav"])
        msg = "https://www.youtube.com/watch?v=ip34OUo3IS0"
        {:ok, msg}

      "!penith" ->
        # shell to mplayer
        System.cmd("play", ["./sfx/penith.wav"])
        msg = ":dizzy:"
        {:ok, msg}

      "!ballin" ->
        # shell to mplayer
        System.cmd("play", ["./sfx/ballin.wav"])
        msg = ":lain_dad:"
        {:ok, msg}

      "!duck" ->
        # shell to mplayer
        System.cmd("play", ["./sfx/duck_rotate.wav"])
        msg = ":duckle:"
        {:ok, msg}

      "!fries" ->
        # shell to mplayer
        System.cmd("mplayer", ["./sfx/greasy_fries.ogg"])
        msg = ":greasyhotdogs:"
        {:ok, msg}

      "!hotdogs" ->
        # shell to mplayer
        System.cmd("mplayer", ["./sfx/greasy_hotd.ogg"])
        msg = ":greasyhotdogs:"
        {:ok, msg}

      "!bug" ->
        # shell to mplayer
        System.cmd("mplayer", ["./sfx/bug.mp3"])
        msg = "FIX THAT BUG"
        {:ok, msg}

      "!gj" ->
        # shell to mplayer
        System.cmd("mplayer", ["./sfx/gj.mp3"])
        msg = ":goodbeverage:"
        {:ok, msg}

      "!false" ->
        # shell to mplayer
        System.cmd("mplayer", ["./sfx/false.mp3"])
        msg = "it never happened"
        {:ok, msg}

      "!totalfabrication" ->
        # shell to mplayer
        System.cmd("mplayer", ["./sfx/total_fabrication.mp3"])
        msg = "it's a total fabrication"
        {:ok, msg}

      "!boost" ->
        # shell to mplayer
        System.cmd("mplayer", ["./sfx/boostyrdesktoplifestyle.mp3"])
        msg = ":marty:"
        {:ok, msg}

      "!computers" ->
        # shell to mplayer
        System.cmd("mplayer", ["./sfx/computers.mp3"])
        msg = "I hope we all learned about computers"
        {:ok, msg}

      "!done" ->
        # shell to mplayer
        System.cmd("mplayer", ["./sfx/done.mp3"])
        msg = "and yr done"
        {:ok, msg}

      "!onionrings" ->
        # shell to mplayer
        System.cmd("mplayer", ["./sfx/greasy_onion_rings.ogg"])
        msg = ":greasyhotdogs:"
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
        { url, username } = Fruitbot.StreampusherApi.user_search(query)
        message = "Datafruit found: #{url}"
        {:ok, message}

      "!bigup" ->
        query_stripped = String.replace_prefix(query, "@", "")
        lookup = :ets.lookup(:user_bigups, query_stripped)
        case lookup do
          [] -> 
            :ets.insert(:user_bigups, {query_stripped, 1})
          [{user, count}] ->
            :ets.insert(:user_bigups, {query_stripped, count + 1})
        end
        [{user, count}] = :ets.lookup(:user_bigups, query_stripped) 
        message = ":airhorn: big up #{user} :airhorn: 88888888888888888+++++++++ #{user} has #{count} bigups"
        { :ok, message }

      "!commands" ->
        # can we pull the list of commands automatically somehow?
        list = """
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

        {:ok, list}

      _ ->
        IO.puts("unhandled command: #{command}")
        # Elixir prefers two-element tuples esp. for :ok and :error
        {:error, :bad_command}
    end
  end
end
