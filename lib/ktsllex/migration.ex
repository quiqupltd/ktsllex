defmodule Ktsllex.Schema.Migration do
  @moduledoc """
  Creates the Kafka schemas and topics as required by config

  ```elixir
    config :ktsllex,
      # Should it run the migration when called? Default: false
      run_migrations: false,
      schema_registry_host: {:system, "AVLIZER_CONFLUENT_SCHEMAREGISTRY_URL", "http://localhost:8081"},
      # Reads the yaml schema file from :
      base_path: {:system, "KAFKA_SCHEMA_BASE_PATH", "./schemas"},
      schema_name: {:system, "KAFKA_SCHEMA_NAME", "schema_name"},
      app_name: :app,
      lenses_host: {:system, "LENSES_HOST", "http://localhost:3030"},
      lenses_user: {:system, "LENSES_USER", "admin"},
      lenses_pass: {:system, "LENSES_PASS", "admin"},
      lenses_topic: {:system, "LENSES_TOPIC", "topic_name"}
  ```
  """

  require Logger

  @spec run() :: :ok
  def run(), do: run_migrations?() |> perform()

  defp perform(true) do
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
