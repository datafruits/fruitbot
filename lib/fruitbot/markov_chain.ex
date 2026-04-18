defmodule Fruitbot.MarkovChain do
  @moduledoc """
  A simple Markov chain text generator backed by a GenServer.

  Ingests chat messages via `train/1` and generates text via `generate/0`.
  Uses bigram (two-word) keys for slightly more coherent output.

  The model is persisted to a plain-text file so it survives restarts.
  Saves happen periodically and on graceful shutdown.
  """

  use GenServer
  require Logger

  @max_sentence_length 50
  @max_next_words 100

  # Save every 5 minutes (in milliseconds)
  @save_interval_ms 5 * 60 * 1_000

  @default_model_path "markov_model.txt"

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

  @doc """
  Manually save the current model to disk.
  """
  @spec save() :: :ok
  def save do
    GenServer.call(__MODULE__, :save)
  end

  # ── Server callbacks ────────────────────────────────────────────────

  @impl true
  def init(_opts) do
    Process.flag(:trap_exit, true)

    state = load_model()
    schedule_save()

    {:ok, state}
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

  @impl true
  def handle_call(:save, _from, state) do
    write_model(state)
    {:reply, :ok, state}
  end

  @impl true
  def handle_info(:save, state) do
    write_model(state)
    schedule_save()
    {:noreply, state}
  end

  @impl true
  def terminate(_reason, state) do
    write_model(state)
    :ok
  end

  # ── Persistence helpers ─────────────────────────────────────────────

  defp schedule_save do
    Process.send_after(self(), :save, @save_interval_ms)
  end

  defp model_path, do: System.get_env("MARKOV_MODEL_PATH") || @default_model_path

  defp load_model do
    case File.read(model_path()) do
      {:ok, contents} ->
        deserialize(contents)

      {:error, :enoent} ->
        %{chain: %{}, starts: []}

      {:error, reason} ->
        Logger.warning("Failed to load Markov model from #{model_path()}: #{inspect(reason)}")
        %{chain: %{}, starts: []}
    end
  end

  defp write_model(%{chain: chain, starts: starts} = _state) when chain == %{} and starts == [] do
    :ok
  end

  defp write_model(state) do
    contents = serialize(state)

    case File.write(model_path(), contents) do
      :ok ->
        Logger.debug("Markov model saved to #{model_path()}")
        :ok

      {:error, reason} ->
        Logger.warning("Failed to save Markov model to #{model_path()}: #{inspect(reason)}")
        :error
    end
  end

  @doc false
  def serialize(%{chain: chain, starts: starts}) do
    chain_lines =
      Enum.flat_map(chain, fn {{w1, w2}, nexts} ->
        Enum.map(nexts, fn w3 ->
          "#{w1}\t#{w2}\t#{w3}"
        end)
      end)

    start_lines =
      Enum.map(starts, fn {w1, w2} ->
        "#{w1}\t#{w2}"
      end)

    Enum.join(chain_lines, "\n") <> "\n\n" <> Enum.join(start_lines, "\n") <> "\n"
  end

  @doc false
  def deserialize(contents) when is_binary(contents) do
    case String.split(contents, "\n\n", parts: 2) do
      [chain_section, starts_section] ->
        chain = parse_chain(chain_section)
        starts = parse_starts(starts_section)
        %{chain: chain, starts: starts}

      [_single_section] ->
        # Only chain data, no starts section
        %{chain: parse_chain(contents), starts: []}
    end
  end

  defp parse_chain(section) do
    section
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn line, acc ->
      case String.split(line, "\t") do
        [w1, w2, w3] ->
          key = {w1, w2}
          Map.update(acc, key, [w3], fn existing -> [w3 | existing] end)

        _ ->
          acc
      end
    end)
  end

  defp parse_starts(section) do
    section
    |> String.split("\n", trim: true)
    |> Enum.reduce([], fn line, acc ->
      case String.split(line, "\t") do
        [w1, w2] -> [{w1, w2} | acc]
        _ -> acc
      end
    end)
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
