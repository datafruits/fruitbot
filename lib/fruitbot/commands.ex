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
          "Enjoying the stream? The best way to support is with a monthly donation on Patreon. Learn more at https://datafruits.fm/support."

        {:ok, msg}

      "!advice" ->
       :random.seed(:erlang.now)
        advices = [
          "Don't live like me Brendon. Don't get a tattoo of a cheese cow.",
          "Next thing you know, you're in the circus, touring, making good money.",
          "I've got trademark products all over my body because I was drunk one night. Don't live  like me.",
          "Your honor might I suggest a spanking on his tush tush?",
          "Quarter for the bus, quarter for the bus. The end. Hey Brendon, the end.",
          "What are you looking at?",
          "It's Spaghetti Time!",
          "Next time that thing comes near me, I'm gonna eat it. I'm serious!",
        ]
        msg = Enum.random(advices)
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

      "!awake" ->
        # shell to mplayer
        System.cmd("mplayer", ["./sfx/alive_alert_awake.mp3"])
        msg = ":alive_alert_awake:"
        {:ok, msg}

      "!beefy" ->
        # shell to mplayer
        System.cmd("play", ["./sfx/beefy.mp4.wav"])
        msg = "beefyeeeyy https://cdn.discordapp.com/attachments/996965279634571306/1238301796502474812/beefy-ezgif.com-video-to-gif-converter.gif?ex=663ec9ea&is=663d786a&hm=dbb09920ade22fea9d7282aa2ba7b4e11af84d778f469944d2ca964657d724f3&"
        {:ok, msg}

      "!next" ->
        next_show = Fruitbot.StreampusherApi.next_show()
        {:ok, next_show}

      "!latest" ->
        # return latest archive
        latest = Fruitbot.StreampusherApi.latest_archive()
        {:ok, latest}

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

      # wait this is already a command...
      # "!hotdogs" ->
      #   { :ok, message }

      "!hack" ->
        message = "hack the planet https://github.com/datafruits"
        { :ok, message }

      "!github" ->
        message = "hack the planet https://github.com/datafruits"
        { :ok, message }

      "!sfx" ->
        # can we pull the list of sfx automatically somehow?
        list = """
        !sorry
        !thisisamazing
        !gohackyourself
        !pewpew
        !bass
        !scream
        !internet
        !penith
        !ballin
        !duck
        !fries
        !hotdogs
        !onionrings
        !gj
        !bug
        !computers
        !done
        !false
        !totalfabrication
        !boost
        """

        {:ok, list}


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
