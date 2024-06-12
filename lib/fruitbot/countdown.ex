defmodule Fruitbot.Countdown do
  def time_left(end_at) do
    {:ok, now} = DateTime.now("Etc/UTC")
    {:ok, then, 0} = DateTime.from_iso8601(end_at)
    seconds_diff = DateTime.diff(then, now)

    days = div(seconds_diff, 86400)
    hours = div(rem(seconds_diff, 86400), 3600)
    minutes = div(rem(seconds_diff, 3600), 60)

    %{ days: days, hours: hours, minutes: minutes }
  end
end
