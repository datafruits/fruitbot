defmodule Fruitbot.Commands do
  def handle_message(command) do
    case command do
      "!vr" ->
        msg = "Join the party in VR here! https://hubs.mozilla.com/MsvfAkH/terrific-satisfied-area"
      "!donate" ->
        msg = "Enjoying the stream? The best way to support is with a monthly donation on ampled. https://www.ampled.com/artist/datafruits You can also make a one time donation to our paypal. https://paypal.me/datafruitsfm"
      "!advice" ->
        msg = "Don't live like me Brendon. Don't get a tattoo of a cheese cow."
        send_message(state.channel, advice)
      "!sorry" ->
        # shell to mplayer
        System.cmd("play", ["./sfx/onion_salad_dressing.mp3"])
        msg = "Must have been the onion salad dressing. Right, Brendon? :sorrymusthavebeentheonionsaladdressing:"
      "!thisisamazing" ->
        # shell to mplayer
        msg = "this is amazing"
        System.cmd("play", ["./sfx/thisisamazing.mp3"])
      "!wtf" ->
        msg = "It's just a website"
      "!next" ->
        next_show = Fruitbot.StreampusherApi.next_show
        msg = next_show
      _ ->
        IO.puts "unhandled body: #{payload["body"]}"
    end
    if msg do
      { :ok, msg }
    else
      { :error }
    end
  end
end
