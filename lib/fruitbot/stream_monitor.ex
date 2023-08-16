defmodule Fruitbot.StreamMonitor do
  @url "https://streampusher-relay.com/datafruits.mp3"
  use HTTPoison.Base

  def start_link(url) do
    HTTPoison.start_link()
    {:ok, %HTTPoison.Config{}} = HTTPoison.Config.default(%{})
    interval = 60_000
    spawn_link(fn -> loop(url, interval) end)
  end

  defp loop(url, interval) do
    :timer.sleep(interval)
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        IO.puts("Success: #{url}")
        loop(url, interval)
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        IO.puts("Error (Status #{status_code}): #{url}")
        # send to which discord channel ???
        loop(url, interval)
      {:error, reason} ->
        IO.puts("Error: #{reason}")
        loop(url, interval)
    end
  end
end
