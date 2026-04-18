defmodule Fruitbot.MarkovChain do
  @moduledoc """
  A simple Markov chain text generator backed by a GenServer.

  Ingests chat messages via `train/1` and generates text via `generate/0`.
  Uses bigram (two-word) keys for slightly more coherent output.
  """

  use GenServer

  @max_sentence_length 50
  @max_next_words 100

  # ── Client API ──────────────────────────────────────────────────────

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Ingest a chat message into the Markov chain model.
  """
  @spec train(String.t()) :: :ok
  def train(text) when is_binary(text) do
    GenServer.cast(__MODULE__, {:train, text})
  end

  @doc """
  Generate a sentence from the Markov chain model.

  Returns `{:ok, text}` or `{:error, :not_enough_data}`.
  """
  @spec generate() :: {:ok, String.t()} | {:error, :not_enough_data}
  def generate do
    GenServer.call(__MODULE__, :generate)
  end

  # ── Server callbacks ────────────────────────────────────────────────

  @impl true
  def init(_opts) do
    # State is a map: {word1, word2} => [word3, …]
    # Plus a special :starts key holding a list of {word1, word2} sentence starters.
    {:ok, %{chain: %{}, starts: []}}
  end

  @impl true
  def handle_cast({:train, text}, state) do
    {:noreply, ingest(state, text)}
  end

  @impl true
  def handle_call(:generate, _from, state) do
    result = build_sentence(state)
    {:reply, result, state}
  end

  # ── Internal helpers ────────────────────────────────────────────────

  defp ingest(state, text) do
    words =
      text
      |> String.split()
      |> Enum.reject(&url?/1)
      |> Enum.take(200)

    if length(words) < 3 do
      state
    else
      triples = Enum.chunk_every(words, 3, 1, :discard)

      Enum.reduce(triples, state, fn [w1, w2, w3], acc ->
        key = {w1, w2}

        chain =
          Map.update(acc.chain, key, [w3], fn existing ->
            if length(existing) >= @max_next_words, do: existing, else: [w3 | existing]
          end)

        %{acc | chain: chain}
      end)
      |> add_start({Enum.at(words, 0), Enum.at(words, 1)})
    end
  end

  defp url?(word) do
    String.starts_with?(word, "http://") or String.starts_with?(word, "https://")
  end

  defp add_start(state, pair) do
    %{state | starts: [pair | state.starts]}
  end

  defp build_sentence(%{starts: []}) do
    {:error, :not_enough_data}
  end

  defp build_sentence(%{chain: chain, starts: starts}) do
    {w1, w2} = Enum.random(starts)
    words = do_walk(chain, w1, w2, [w1, w2], @max_sentence_length)
    {:ok, Enum.join(Enum.reverse(words), " ")}
  end

  defp do_walk(_chain, _w1, _w2, acc, 0), do: acc

  defp do_walk(chain, w1, w2, acc, remaining) do
    case Map.get(chain, {w1, w2}) do
      nil ->
        acc

      nexts ->
        w3 = Enum.random(nexts)
        do_walk(chain, w2, w3, [w3 | acc], remaining - 1)
    end
  end
end
