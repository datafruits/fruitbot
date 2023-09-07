defmodule Fruitbot.Twitch do
  @moduledoc false
  use TMI

  @impl true
  def handle_message("!" <> command, sender, channel, _tags) do
    Logger.debug("hey: #{command}, #{sender}, #{channel}")
    case Fruitbot.Commands.handle_message("!#{command}") do
      {:ok, message} ->
        say(channel, message)
      _ ->
        say(channel, "unrecognized command")
    end
  end

  def handle_message(message, sender, channel, _tags) do
    Logger.debug("Message in #{channel} from #{sender}: #{message}")
  end
end
