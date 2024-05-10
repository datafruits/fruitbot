defmodule Fruitbot.CommandHandler do
  import Fruitbot.Commands, only: [all_commands: 0]

  def handle_command(payload) do
    IO.inspect(payload)
    [command | tail] = String.split(payload)
    query = Enum.join(tail)

    case find_command(command) do
      nil -> IO.puts("Command not found")
      c -> execute_command(c)
    end
  end

  defp find_command(message) do
    IO.puts(message)
    Enum.find(all_commands(), fn command ->
      IO.puts(command.aliases)
      c = message |> String.split("!") |> List.last()
      IO.puts(c)
      Enum.any?(command.aliases, &(&1 == c))
    end)
  end

  defp execute_command(%Fruitbot.Command{handler: handler}) do
    handler.()
  end
end
