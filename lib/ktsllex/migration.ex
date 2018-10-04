defmodule Ktsllex.Schema.Migration do
  @moduledoc """
  Creates the Kafka schemas and topics as required by config

  ```elixir
  config :ktsllex,
    # Should it run the migration when called? Default: true
    run_migrations: true,
    schema_registry_host: "http://localhost:8081",
    schema_name: "schema_name",
    # Need to know where the app is to get the path to the schema files
    app_name: :your_otp_app_name,
    base_path: "./schemas/file/location",
    lenses_host: "http://localhost:3030",
    lenses_user: "admin",
    lenses_pass: "admin",
    lenses_topic: "lenses_topic"
  ```
  """

  require Logger

  @spec run() :: :ok
  def run(), do: run_migrations?() |> perform()

  defp perform(true) do
    base_path() |> IO.inspect(label: "base_path")

    Ktsllex.Schemas.run(schema_registry_host(), schema_name(), schema_path())
    Ktsllex.Topics.run(lenses_host(), lenses_user(), lenses_pass(), lenses_topic())

    :ok
  end

  defp perform(_), do: Logger.info("#{__MODULE__} schema migration disabled")

  defp schema_path(), do: app_path() <> "/" <> base_path()

  defp app_path(), do: :code.priv_dir(app_name()) |> to_string()

  defp run_migrations?, do: Application.get_env(:ktsllex, :run_migrations, false)

  defp schema_registry_host, do: Application.get_env(:ktsllex, :schema_registry_host)
  defp schema_name, do: Application.get_env(:ktsllex, :schema_name)
  defp app_name, do: Application.get_env(:ktsllex, :app_name)
  defp base_path, do: Application.get_env(:ktsllex, :base_path)

  defp lenses_host, do: Application.get_env(:ktsllex, :lenses_host)
  defp lenses_user, do: Application.get_env(:ktsllex, :lenses_user)
  defp lenses_pass, do: Application.get_env(:ktsllex, :lenses_pass)
  defp lenses_topic, do: Application.get_env(:ktsllex, :lenses_topic)
end
