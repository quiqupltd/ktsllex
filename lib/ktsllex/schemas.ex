defmodule Ktsllex.Schemas do
  @moduledoc """
  This sets up the schemas as required to run.
  """

  use Confex, otp_app: :ktsllex
  require Logger
  alias Ktsllex.FileJson

  @doc """
  Creates key and value schemas with schema_name on host, loading json schemas from base_schema_file

  ### Params

  * `host` - A kafka broker, eg localhost:8081
  * `schema_name` - The schema name to register the schemas as
      * Replaces the schema_name in the schema files with the one provided
  * `base_schema_file` - The path to the schema file
      * eg "./schemas/file"
      * Expects to find a single file for a schema with the following structure
      * {
      *   "name": "test",
      *   "key_avro_schema": {},
      *   "value_avro_schema": {}
      * }

      * eg "schemas/file.json"

  ### Example

  iex> Schemas.run("localhost:8081", "schema-name", "./schemas/file")

  The above would make two HTTP post requests to:
  * http://localhost:8081/subjects/schema-name-value/versions
  * http://localhost:8081/subjects/schema-name-key/versions

  With the schema loaded from `schemas/file.json`,
  in which the `namespace` within the schema is updated to `schema-name`

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
    Logger.info(
      "#{__MODULE__} Creating schemas on:#{inspect(host)} with name:#{inspect(schema_name)} from:#{
        inspect(base_schema_file)
      }"
    )

    ["key", "value"]
    |> Enum.map(fn type -> process(host, schema_name, base_schema_file, type) end)
  end

  defp process(host, schema_name, base_schema_file, type) do
    url = build_url(host, schema_name, type)
    schema = build_schema(base_schema_file, schema_name, type)

    case schema do
      :error ->
        :error

      _ ->
        url
        |> post(schema)
        |> extract_body()
        |> Poison.decode!()
        |> output_result()
    end
  end

  defp build_url(host, schema_name, key_or_value) do
    host <> "/subjects/" <> schema_name <> "-" <> key_or_value <> "/versions"
  end

  # Overwrite schema name in provided base schema with given schema name
  defp build_schema(base_schema_file, schema_name, type) do
    base_schema_file
    |> read_schema(type)
    |> update_namespace(schema_name)
    |> update_connect_name(schema_name, type)
  end

  defp update_namespace({:error, _}, _schema_name) do
    Logger.error("Error reading schema files")
    :error
  end

  defp update_namespace(schema, schema_name) do
    schema
    |> Map.put("namespace", schema_name)
  end

  defp update_connect_name(:error, _schema_name, _type), do: :error
  defp update_connect_name(schema, _schema_name, "value"), do: schema

  defp update_connect_name(schema, schema_name, "key") do
    schema
    |> Map.put("connect.name", schema_name <> ".Key")
  end

  defp read_schema(base_schema_file, type) do
    json_file =
      (base_schema_file <> ".json")
      |> FileJson.read!()

    case json_file do
      %{"key_avro_schema" => key_schema, "value_avro_schema" => value_schema} ->
        case type do
          "key" -> key_schema
          "value" -> value_schema
        end
      _ ->
        {:error, :enoent}
    end
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

  defp output_result(result) do
    Logger.info("#{__MODULE__} created schema #{inspect(result)}")
  end

  defp http_client(), do: config()[:http_client] || HTTPoison
end
