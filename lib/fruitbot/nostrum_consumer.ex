defmodule Fruitbot.NostrumConsumer do
  use Nostrum.Consumer

  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, ws_state}) do
    IO.inspect ws_state
    # IO.inspect msg
    { :ok, message } = Fruitbot.Commands.handle_message msg.content
    Api.create_message(msg.channel_id, message)
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
