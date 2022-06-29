defmodule Fruitbot.Worker do
  use GenServer

  alias PhoenixClient.{Socket, Channel, Message}

  def start_link(_opts) do
    IO.puts "starting worker..."
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
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

  # defp get_state, do: GenServer.call(__MODULE__, :get_state)
  #
  # def handle_call(:get_state, _from, state), do: {:reply, state, state}

  def handle_cast({:send_discord_msg, msg}, state) do
    IO.puts "sending discord msg to datafruits chat..."
    IO.puts inspect state
    message = "New msg in discord from #{msg.author.username}: #{msg.content}"
    send_message(state.channel, message)
    {:noreply, state}
  end

  defp send_message(channel, body) do
    channel_msg = %{
      user: "coach",
      body: body,
      timestamp: :os.system_time(:millisecond),
      bot: true,
      avatarUrl: "https://dongles-dev.streampusher-relay.club/images/thumb/mcguirk.png?1616065459"
    }
    { :ok, message } = Channel.push(channel, "new:msg", channel_msg)
    { :ok, message }
  end

  def handle_info(%Message{payload: payload}, state) do
    IO.puts "Incoming Message: #{inspect payload}"
    if Map.has_key?(payload, "body") do
      IO.puts "payload body: #{payload["body"]}"
      case payload["body"] do
        "!advice" ->
          advice = "Don't live like me Brendon. Don't get a tattoo of a cheese cow."
          send_message(state.channel, advice)
        "!next" ->
          next_show = Fruitbot.StreampusherApi.next_show
          send_message(state.channel, next_show)
        _ ->
          IO.puts "unhandled body: #{payload["body"]}"
      end
    end
    { :noreply, state }
  end

  # def handle_info(%Message{payload: payload}, state) do
  #   IO.puts "Incoming Message: #{inspect payload}"
  #   {:noreply, state}
  # end
end
