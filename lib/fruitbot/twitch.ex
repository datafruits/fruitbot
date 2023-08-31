defmodule Fruitbot.Twitch do
  use TMI

  @impl TMI.Handler
  def handle_message("!" <> command, sender, chat) do
    Logger.debug("hey: #{command}")
    case Fruitbot.Commands.handle_message(command) do
      {:ok, message} ->
        say(chat, message)
      _ ->
        say(chat, "unrecognized command")
    end
  end

  def handle_message(message, sender, chat) do
    Logger.debug("Message in #{chat} from #{sender}: #{message}")
  end
end
