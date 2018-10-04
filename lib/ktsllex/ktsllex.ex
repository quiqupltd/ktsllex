defmodule Ktsllex do
  use Application

  @moduledoc """
  If the client application wants to run the schema migrations at boot

  ```elixir
        extra_applications: [
          :logger,
          ...
          :ktsllex,
          ...
          :event_serializer
  ```
  """

  @spec start(any(), any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start(_type, _args) do
    Confex.resolve_env!(:ktsllex)
    Ktsllex.Schema.Migration.run()
    Supervisor.start_link([], strategy: :one_for_one)
  end
end
