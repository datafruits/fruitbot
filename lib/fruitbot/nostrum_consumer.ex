defmodule Fruitbot.NostrumConsumer do
  use Nostrum.Consumer

  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, ws_state}) do
    IO.inspect ws_state
    # IO.inspect state
    case msg.content do
      "!sleep" ->
        Api.create_message(msg.channel_id, "Going to sleep...")
        # This won't stop other events from being handled.
        Process.sleep(3000)

      "!ping" ->
        Api.create_message(msg.channel_id, "pyongyang!")

      "!raise" ->
        # This won't crash the entire Consumer.
        raise "No problems here!"

      _ ->
        IO.puts "unhandled event"
        IO.puts inspect msg
        IO.puts inspect msg.author
        # state = get_state
        # IO.puts inspect state
        # Channel.push(Map.fetch(state, :channel), "new:msg", %{user: "coach", body: "New msg in discord from #{msg.author.username}: #{msg.content}"})
        IO.puts "is it #{msg.author.username} bot: #{msg.author.bot}"
        if msg.author.bot != true do
          IO.puts "NOT a bot"
          GenServer.cast(Fruitbot.Worker, {:send_discord_msg, msg})
        end
        :ignore
    end
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end
end
