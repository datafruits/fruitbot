defmodule Fruitbot.NostrumConsumer do
  @just_a_website_channel_id 918577903258730506
  @behaviour Nostrum.Consumer

  alias Nostrum.Api

  def handle_event({:MESSAGE_CREATE, msg, ws_state}) do
    IO.inspect(ws_state)
    IO.inspect msg
    IO.puts "new message in channel: #{msg.channel_id}"
    if msg.channel_id == @just_a_website_channel_id do
      if msg.author.bot != true do
        IO.puts("NOT a bot")
        send_discord_message(msg)
        
        # Handle commands if message starts with !
        if String.starts_with?(msg.content, "!") do
          case Fruitbot.CommandHandler.handle_command(msg.content) do
            {:ok, message} ->
              Nostrum.Api.Message.create(msg.channel_id, message)

            {:error, :bad_command} ->
              # noop
              IO.puts("not a command")
              :ignore
              
            _ ->
              :ignore
          end
        end
      end
    end
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end

  def send_discord_message(message) do
    GenServer.cast(Fruitbot.Worker, {:send_discord_msg, message})
  end
end
