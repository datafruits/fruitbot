defmodule Fruitbot.StreampusherApi do
  def user_search(query) do
    response =
      case HTTPoison.get!("https://datafruits.streampusher.com/api/wiki_pages.json?q=#{query}") do
        %HTTPoison.Response{status_code: 200, body: body} ->
          Jason.decode!(body)

        # not sure it seems the API doesn't return a 404 when search result not found, just an empty list
        %HTTPoison.Response{status_code: 404} ->
        # following suit in your last comment and changing IO.puts function for directly evaluating string
          "#{query} not found"

        # elixis LS for some reason tells me an error won't occur, dunno why, but we can just use a catch-all for any response besides success
        _ ->
          "Whoops must have eaten a bad fruit"

          # %HTTPoison.Error{reason: reason} ->
        #   IO.inspect(reason)
      end

    data = response["data"]
    first_result = Enum.at(data, 0)
    slug = Kernel.get_in(first_result, ["attributes", "slug"])
    title = Kernel.get_in(first_result, ["attributes", "title"])
    url = "https://datafruits.fm/wiki/#{slug}"
    "Datafruits has what you're looking for. Check out the article #{title} at :link: #{url}"
  end

  def next_show do
    response =
      case HTTPoison.get!("https://datafruits.streampusher.com/scheduled_shows/next.json") do
        %HTTPoison.Response{status_code: 200, body: body} ->
          Jason.decode!(body)

        # not sure it seems the API doesn't return a 404 when search result not found, just an empty list
        %HTTPoison.Response{status_code: 404} ->
          "Not found"

        # elixis LS for some reason tells me an error won't occur, dunno why, but we can just use a catch-all for any response besides success
        _ ->
          "Whoops must have eaten a bad fruit"

        # %HTTPoison.Error{reason: reason} ->
        #   IO.inspect(reason)
      end

    data = response["data"]
    title = Kernel.get_in(data, ["attributes", "title"])
    host = Kernel.get_in(data, ["attributes", "hosted_by"])
    description = Kernel.get_in(data, ["attributes", "description"])
    slug = Kernel.get_in(data, ["attributes", "slug"])
    url = "https://datafruits.fm/shows/#{slug}"
    "Next show is #{title}, hosted by #{host}! Description: #{description}. :link: #{url}"
  end

  # def today do
  #
  # end
end
