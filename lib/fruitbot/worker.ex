defmodule Fruitbot.Worker do
  use GenServer
  use Nostrum.Consumer

  alias PhoenixClient.{Socket, Channel, Message}
  alias Nostrum.Api

  def start_link() do
    IO.puts "starting worker..."
    GenServer.start_link(__MODULE__, [])
    Consumer.start_link(__MODULE__)
  end

  def init(_opts) do
    socket_opts = [
      url: System.get_env("CHAT_URL")
    ]

    {:ok, socket} = PhoenixClient.Socket.start_link(socket_opts)
    wait_until_connected(socket)

    {:ok, _response, channel} = Channel.join(socket, "rooms:lobby")
    # set username here?
    Channel.push(channel, "authorize", %{user: "coach"})
    {:ok, %{
      channel: channel
    }}
  end

  defp wait_until_connected(socket) do
    if !PhoenixClient.Socket.connected?(socket) do
      Process.sleep(100)
      wait_until_connected(socket)
    end
  end

  defp get_state, do: GenServer.call(__MODULE__, :get_state)

  def handle_call(:get_state, _from, state), do: {:reply, state, state}

  def handle_info(%Message{payload: payload}, state) do
    IO.puts "Incoming Message: #{inspect payload}"
    {:noreply, state}
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
        state = get_state
        Channel.push(state["channel"], "new:msg", %{user: "coach", body: "New msg in discord from #{msg.username}: #{msg.content}"})
        # GenServer.call(this, {:send_discord_msg, msg})
        :ignore
    end
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end
end
