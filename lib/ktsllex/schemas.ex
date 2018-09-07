defmodule Ktsllex.Schemas do
  @moduledoc """
  This sets up the schemas as required to run.
  """

  use Confex, otp_app: :ktsllex

  alias Ktsllex.FileJson

  @doc """
  Creates key and value schemas with schema_name on host, loading json schemas from base_schema_file

  ### Params

  * `host` - A kafka broker, eg localhost:8081
  * `schema_name` - The schema name to register the schemas as
      * Replaces the schema_name in the schema files with the one provided
  * `base_schema_file` - The path to the schema files
      * eg "./schemas/tracking_locations"
      * Expects to find two files, one ending `-key.json` and one `-value.json`
      * eg "schemas/tracking_locations-key.json"

  ### Example

  iex> Schemas.run("localhost:8081", "uk.london.quiqup.tracking_locations", "./schemas/tracking_locations")

  The above would make two HTTP post requests to:
  * http://localhost:8081/subjects/uk.london.quiqup.tracking_locations-value/versions
  * http://localhost:8081/subjects/uk.london.quiqup.tracking_locations-key/versions

  With the schema loaded from `schemas/tracking_locations-key.json` and `schemas/tracking_locations-value.json`,
  in which the `namespace` within the schema is updated to `uk.london.quiqup.tracking_locations`

  More info on the API here:

  https://docs.confluent.io/current/schema-registry/docs/api.html#post--subjects-(string-%20subject)-versions

  A manual curl example:
  ```
  curl -X POST \
    http://localhost:8081/subjects/schema_name/versions \
    -H 'Content-Type: application/json' \
    -d '{
      "schema":
      "{ \"type\": \"record\", \"name\": \"Key\", \"namespace\": \"schema_name\", \"fields\": [ { \"name\": \"id\", \"type\": \"int\"} ], \"connect.name\": \"schema_name\" }"
    }'
  ```
  """
  def run(host, schema_name, base_schema_file) do
    ["-key", "-value"]
    |> Enum.map(fn type -> process(host, schema_name, base_schema_file, type) end)
  end

  defp process(host, schema_name, base_schema_file, type) do
    url = build_url(host, schema_name, type)
    schema = build_schema(base_schema_file, schema_name, type)

    post(url, schema)
    |> extract_body()
    |> Poison.decode!()
    |> inspect
    |> IO.puts()
  end

  defp build_url(host, schema_name, key_or_value) do
    host <> "/subjects/" <> schema_name <> key_or_value <> "/versions"
  end

  # Overwrite schema name in provided base schema with given schema name
  defp build_schema(base_schema_file, schema_name, type) do
    read_schema(base_schema_file, type)
    |> Map.put("namespace", schema_name)
    |> update_connect_name(schema_name, type)
  end

  defp update_connect_name(schema, _schema_name, "-value"), do: schema

  defp update_connect_name(schema, schema_name, "-key") do
    schema
    |> Map.put("connect.name", schema_name <> ".Key")
  end

  defp read_schema(base_schema_file, type) do
    (base_schema_file <> type <> ".json")
    |> FileJson.read!()
  end

  defp post(url, schema) do
    encoded_schema =
      schema
      |> Poison.encode!()
      |> Poison.encode!()

    body = ~s({"schema":) <> encoded_schema <> "}"

    http_client().post(url, body, [{"Content-Type", "application/json"}])
  end

  defp extract_body({:ok, %HTTPoison.Response{body: body}}), do: body

  defp http_client(), do: config()[:http_client]
end
