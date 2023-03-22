defmodule Fruitbot.Commands do
  def handle_message(payload) do
    [ command | tail ] = String.split(payload)
    args = List.first(tail)
    msg = ""
    case command do
      "!vr" ->
        msg = "Join the party in VR here! https://hubs.mozilla.com/MsvfAkH/terrific-satisfied-area"
      "!donate" ->
        msg = "Enjoying the stream? The best way to support is with a monthly donation on ampled. https://www.ampled.com/artist/datafruits You can also make a one time donation to our paypal. https://paypal.me/datafruitsfm"
      "!advice" ->
        msg = "Don't live like me Brendon. Don't get a tattoo of a cheese cow."
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
      "!wiki" ->
        wiki_link = Fruitbot.StreampusherApi.search_wiki(args)
        msg = wiki_link
      _ ->
        IO.puts "unhandled command: #{msg}"
    end
    if msg do
      { :ok, msg }
    else
      { :error }
    end
  end
end
