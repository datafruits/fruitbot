defmodule Fruitbot.Commands do
  defmodule Handlers do
    def say_commands(_query) do
      commands = Enum.join(Enum.map(Fruitbot.Commands.all_commands(), fn %Fruitbot.Command{aliases: [first | _rest]} -> "!" <> first end), " ")
      {:ok, commands}
    end

    def say_anysong(_query) do
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
    end

    def say_discord(_query) do
      msg = "https://discord.gg/kM3bW7SM"
      {:ok, msg}
    end

    def say_donate(_query) do
      msg =
        "Enjoying the stream? The best way to support is with a monthly donation on Patreon. Learn more at https://datafruits.fm/support."

      {:ok, msg}
    end

    # def say_advice(_query) do
    #  {:ok, model} = Markov.load("./coach_model", sanitize_tokens: true, store_log: [:train])
    #  :ok = Markov.configure(model, shift_probabilities: true)
    #
    #  {:ok, msg} = Markov.generate_text(model)
    #  Markov.unload(model)
    #  {:ok, msg}
    # end
    #
    def say_next(_query) do
      next_show = Fruitbot.StreampusherApi.next_show()
      {:ok, next_show}
    end

    def say_np(_query) do
      current_show = Fruitbot.StreampusherApi.current_show()
      # return current show if exists or current archive playing
      {:ok, current_show}
    end

    def say_latest(_query) do
      # return latest archive
      latest = Fruitbot.StreampusherApi.latest_archive()
      {:ok, latest}
    end

    def say_wiki(query) do
      wiki_link = Fruitbot.StreampusherApi.wiki_search(query)
      {:ok, wiki_link}
    end

    def say_tag(query) do
      result = Fruitbot.StreampusherApi.tag_search(query)
      {:ok, result}
    end

    def say_shrimpo(query) do
      result = Fruitbot.StreampusherApi.current_shrimpos()
      {:ok, result}
    end

    def say_datafruiter(query) do
      result = Fruitbot.StreampusherApi.user_search(query)
      case result do
        { url, username } ->
          message = "Datafruit found: #{url}"
          {:ok, message}
        { :error, error_message } ->
          message = error_message
          {:ok, message}
      end
    end

    def say_bigup(query) do
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
    end

    def say_hack(_query) do
      message = "hack the planet https://github.com/datafruits"
      { :ok, message }
    end

    def say_help(_query) do
      message = "type !commands to see list of commands or check out the !wiki for more info"
      { :ok, message }
    end

    def say_label(_query) do
      message = "check out the datafruits label releases here https://datafruits.bandcamp.com/"
      { :ok, message }
    end

    def say_coc(_query) do
      message = "all fruits must abide by the code of conduct https://datafruits.fm/coc"
      { :ok, message }
    end
  end

  @commands [
    %Fruitbot.Command{aliases: ["commands"], handler: &Handlers.say_commands/1},
    %Fruitbot.Command{aliases: ["anysong"], handler: &Handlers.say_anysong/1},
    %Fruitbot.Command{aliases: ["discord"], handler: &Handlers.say_discord/1},
    %Fruitbot.Command{aliases: ["donate", "patreon", "subscribe"], handler: &Handlers.say_donate/1},
    # %Fruitbot.Command{aliases: ["advice"], handler: &Handlers.say_advice/1},
    %Fruitbot.Command{aliases: ["next"], handler: &Handlers.say_next/1},
    %Fruitbot.Command{aliases: ["np", "now"], handler: &Handlers.say_np/1},
    %Fruitbot.Command{aliases: ["latest"], handler: &Handlers.say_latest/1},
    %Fruitbot.Command{aliases: ["wiki"], handler: &Handlers.say_wiki/1},
    %Fruitbot.Command{aliases: ["tag"], handler: &Handlers.say_tag/1},
    %Fruitbot.Command{aliases: ["shrimpo", "shrimpos"], handler: &Handlers.say_shrimpo/1},
    %Fruitbot.Command{aliases: ["datafruiter", "datafruit"], handler: &Handlers.say_datafruiter/1},
    %Fruitbot.Command{aliases: ["bigup", "bigups"], handler: &Handlers.say_bigup/1},
    %Fruitbot.Command{aliases: ["hack", "github"], handler: &Handlers.say_hack/1},
    %Fruitbot.Command{aliases: ["help"], handler: &Handlers.say_help/1},
    %Fruitbot.Command{aliases: ["label", "bandcamp"], handler: &Handlers.say_label/1},
    %Fruitbot.Command{aliases: ["coc", "conduct"], handler: &Handlers.say_coc/1},
  ]

  def all_commands(), do: @commands
end
