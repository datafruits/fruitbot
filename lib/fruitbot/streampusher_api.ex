defmodule Fruitbot.StreampusherApi do
  @moduledoc """
  Functions called by user commands from the Datafruits chat.
  """

  @spec user_search(String.t()) :: String.t()
  def user_search(query) do
    case HTTPoison.get!("https://datafruits.streampusher.com/api/djs/#{query}.json?name=#{query}") do
      %HTTPoison.Response{status_code: 200, body: body} ->
        response = Jason.decode!(body)
        data = response["data"]
        username = data["attributes"]["username"]
        url = "https://datafruits.fm/djs/#{username}"
        { url, username }

      %HTTPoison.Response{status_code: 404} ->
        "#{query} not found"

      _ ->
        "Whoops must have eaten a bad fruit"

        # %HTTPoison.Error{reason: reason} ->
        #   IO.inspect(reason)
    end
  end

  @spec tag_search(String.t()) :: String.t()
  def tag_search(query) do
    response =
      case HTTPoison.get!("https://datafruits.streampusher.com/api/archives.json?tags=#{query}") do
        %HTTPoison.Response{status_code: 200, body: body} ->
          response = Jason.decode!(body)

          data = response["data"]
          first_result = Enum.at(data, 0)
          slug = Kernel.get_in(first_result, ["attributes", "slug"])
          show_series_slug = Kernel.get_in(first_result, ["attributes", "show_series_slug"])
          url = "https://datafruits.fm/wiki/#{slug}"

          "https://datafruits.fm/shows/#{show_series_slug}/episodes/#{slug}"

        %HTTPoison.Response{status_code: 404} ->
          "couldn't find any archives tagged with #{query}. musta been the onion salad dressing."

        _ ->
          "Whoops must have eaten a bad fruit"

          # %HTTPoison.Error{reason: reason} ->
          #   IO.inspect(reason)
      end
  end

  @spec wiki_search(String.t()) :: String.t()
  def wiki_search(query) do
    case HTTPoison.get!("https://datafruits.streampusher.com/api/wiki_pages.json?q=#{query}") do
      %HTTPoison.Response{status_code: 200, body: body} ->
        response = Jason.decode!(body)
        data = response["data"]
        first_result = Enum.at(data, 0)
        slug = Kernel.get_in(first_result, ["attributes", "slug"])
        title = Kernel.get_in(first_result, ["attributes", "title"])
        url = "https://datafruits.fm/wiki/#{slug}"

        "Datafruits has what you're looking for. Check out the Fruitstopiyeah wiki article #{title} at :link: #{url}"

      # not sure it seems the API doesn't return a 404 when search result not found, just an empty list
      %HTTPoison.Response{status_code: 404} ->
        "#{query} not found in the Fruitstopiyeah wiki. Maybe you should add it? https://datafruits.fm/wiki/new"

      _ ->
        "Whoops must have eaten a bad fruit"

        # %HTTPoison.Error{reason: reason} ->
        #   IO.inspect(reason)
    end
  end

  @spec next_show() :: String.t()
  def next_show do
    response =
      case HTTPoison.get!("https://datafruits.streampusher.com/scheduled_shows/next.json") do
        %HTTPoison.Response{status_code: 200, body: body} ->
          Jason.decode!(body)

        # not sure it seems the API doesn't return a 404 when search result not found, just an empty list
        %HTTPoison.Response{status_code: 404} ->
          "Not found"

        _ ->
          "Whoops must have eaten a bad fruit"

          # %HTTPoison.Error{reason: reason} ->
          #   IO.inspect(reason)
      end

    data = response["data"]
    start = Kernel.get_in(data, ["attributes", "start"])
    {:ok, now} = DateTime.now("Etc/UTC")
    {:ok, then, 0} = DateTime.from_iso8601(start)
    IO.puts now
    IO.puts then
    countdown = DateTime.diff(then, now) |> Kernel./(60) |> Kernel.trunc()
    IO.puts countdown

    title = Kernel.get_in(data, ["attributes", "title"])
    host = Kernel.get_in(data, ["attributes", "hosted_by"])
    description = Kernel.get_in(data, ["attributes", "description"])
    slug = Kernel.get_in(data, ["attributes", "slug"])
    show_series_slug = Kernel.get_in(data, ["attributes", "show_series_slug"])
    url = "https://datafruits.fm/shows/#{show_series_slug}/episodes/#{slug}"
    image_url = Kernel.get_in(data, ["attributes", "thumb_image_url"])
    "Next show is #{title}, hosted by #{host}! Beginning in #{countdown} minutes. Description: #{description}. :link: #{url} #{image_url}"
  end

  @spec latest_archive() :: String.t()
  def latest_archive do
    response =
      case HTTPoison.get!("https://datafruits.streampusher.com/api/archives.json") do
        %HTTPoison.Response{status_code: 200, body: body} ->
          response = Jason.decode!(body)

          data = response["data"]
          first_result = Enum.at(data, 0)
          slug = Kernel.get_in(first_result, ["attributes", "slug"])
          show_series_slug = Kernel.get_in(first_result, ["attributes", "show_series_slug"])
          url = "https://datafruits.fm/wiki/#{slug}"

          "https://datafruits.fm/shows/#{show_series_slug}/episodes/#{slug}"

        # not sure it seems the API doesn't return a 404 when search result not found, just an empty list
        %HTTPoison.Response{status_code: 404} ->
          "Not found"

        _ ->
          "Whoops must have eaten a bad fruit"

          # %HTTPoison.Error{reason: reason} ->
          #   IO.inspect(reason)
      end
  end
end
