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

      "!np" ->
        {:ok, resp} = :httpc.request(:get, {'https://streampusher-relay.club/status-json.xsl', []}, [], [body_format: :json])
        json = elem(resp, 2)
        {:ok, decoded } = Jason.decode(json)
        np = Enum.at(decoded["icestats"]["source"], 0)["yp_currently_playing"]

        Api.create_message(msg.channel_id, np)

      "!advice" ->
        advice = "Don't live like me Brendon. Don't get a tattoo of a cheese cow."

        Api.create_message(msg.channel_id, advice)

      "!next" ->
        # get next scheduled show
        next_show = Fruitbot.StreampusherApi.next_show
        Api.create_message(msg.channel_id, next_show)

      # "!today" ->
        # get today's schedule

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
          send_discord_message(msg)
        end
        :ignore
    end
  end

  def send_discord_message(message) do
    GenServer.cast(Fruitbot.Worker, {:send_discord_msg, message})
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end
end
