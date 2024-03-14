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
       {:ok, model} = Markov.load("./coach_model", sanitize_tokens: true, store_log: [:train])
       :ok = Markov.configure(model, shift_probabilities: true)

       {:ok, msg} = Markov.generate_text(model)
       Markov.unload(model)
       {:ok, msg}

      "!next" ->
        next_show = Fruitbot.StreampusherApi.next_show()
        {:ok, next_show}

      "!np" ->
        current_show = Fruitbot.StreampusherApi.current_show()
        # return current show if exists or current archive playing
        {:ok, current_show}

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

      "!commands" ->
        # can we pull the list of commands automatically somehow?
        list = """
        !vr
        !donate
        !advice
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
