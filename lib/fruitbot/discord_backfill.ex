defmodule Fruitbot.DiscordBackfill do
  @moduledoc """
  Fetches historical messages from a Discord channel and feeds them
  into the Markov chain for training.

  Paginates backwards through channel history using
  `Nostrum.Api.get_channel_messages/3` with the `:before` locator.

  Usage from IEx:

      Fruitbot.DiscordBackfill.run(918577903258730506)

  Or via the `!backfill` chat command.
  """

  require Logger

  @page_size 100
  # Pause between pages to stay well within Discord rate limits
  @rate_limit_ms 1_000

  @doc """
  Asynchronously backfill the Markov chain from a Discord channel's history.

  Spawns a `Task` so the caller is not blocked.
  Returns `{:ok, pid}` of the background task.
  """
  @spec run(non_neg_integer()) :: {:ok, pid()}
  def run(channel_id) do
    task =
      Task.start(fn ->
        Logger.info("DiscordBackfill: starting backfill for channel #{channel_id}")
        count = fetch_all(channel_id)
        Logger.info("DiscordBackfill: finished — trained on #{count} messages")

        # Persist the model immediately after bulk ingestion
        Fruitbot.MarkovChain.save()
      end)

    task
  end

  @doc false
  def fetch_all(channel_id) do
    fetch_page(channel_id, nil, 0)
  end

  defp fetch_page(channel_id, before_id, count) do
    case fetch_messages(channel_id, before_id) do
      {:ok, []} ->
        count

      {:ok, messages} ->
        trainable_msgs = Enum.filter(messages, &trainable?/1)

        Enum.each(trainable_msgs, fn msg ->
          Fruitbot.MarkovChain.train(msg.content)
        end)

        new_count = count + length(trainable_msgs)
        oldest_id = messages |> Enum.map(& &1.id) |> Enum.min()

        Logger.debug("DiscordBackfill: fetched #{length(messages)} messages, trained #{new_count} total so far")

        Process.sleep(@rate_limit_ms)
        fetch_page(channel_id, oldest_id, new_count)

      {:error, reason} ->
        Logger.warning("DiscordBackfill: API error — #{inspect(reason)}, stopping at #{count} messages")
        count
    end
  end

  defp fetch_messages(channel_id, nil),
    do: Nostrum.Api.get_channel_messages(channel_id, @page_size)

  defp fetch_messages(channel_id, before_id),
    do: Nostrum.Api.get_channel_messages(channel_id, @page_size, %{before: before_id})

  defp trainable?(msg) do
    not bot?(msg) and
      not command?(msg.content) and
      has_content?(msg.content)
  end

  defp bot?(%{author: %{bot: true}}), do: true
  defp bot?(_), do: false

  defp command?(content) when is_binary(content), do: String.starts_with?(content, "!")
  defp command?(_), do: false

  defp has_content?(content) when is_binary(content), do: String.trim(content) != ""
  defp has_content?(_), do: false
end
