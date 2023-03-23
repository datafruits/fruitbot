defmodule Fruitbot.Commands do
  def handle_message(payload_body) do
    [ command | tail ] = String.split(payload_body)
    args = Enum.join(tail, " ")
    msg =
    case command do
      "!vr" ->
        "Join the party in VR here! https://hubs.mozilla.com/MsvfAkH/terrific-satisfied-area"
      "!donate" ->
        "Enjoying the stream? The best way to support is with a monthly donation on ampled. https://www.ampled.com/artist/datafruits You can also make a one time donation to our paypal. https://paypal.me/datafruitsfm"
      "!advice" ->
        "Don't live like me Brendon. Don't get a tattoo of a cheese cow."
      "!sorry" ->
        # shell to mplayer
        System.cmd("play", ["./sfx/onion_salad_dressing.mp3"])
        "Must have been the onion salad dressing. Right, Brendon? :sorrymusthavebeentheonionsaladdressing:"
      "!thisisamazing" ->
        # shell to mplayer
        "this is amazing"
        System.cmd("play", ["./sfx/thisisamazing.mp3"])
      "!wtf" ->
        "It's just a website"
      "!next" ->
        next_show = Fruitbot.StreampusherApi.next_show
        next_show
      "!wiki" ->
        wiki_link = Fruitbot.StreampusherApi.search_wiki(args)
        wiki_link
      _ ->
        IO.puts "unhandled command"
    end
    if msg do
      {:ok, msg}
    else
      {:error}
    end
  end
end
