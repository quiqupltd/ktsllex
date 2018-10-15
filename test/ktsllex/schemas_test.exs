defmodule Ktsllex.SchemasTest do
  use ExUnit.Case, async: true

  alias Ktsllex.Schemas, as: Schemas

  defmodule HTTPoisonMock do
    def post(url, body, headers) do
      send(:current_test, %{url: url, body: body, headers: headers})

      %{id: 1}
      |> Poison.encode!()
      |> mock_http_poison_response(200)
    end

    defp mock_http_poison_response(body, status_code) do
      {:ok, %HTTPoison.Response{body: body, status_code: status_code}}
    end
  end

  setup do
    config = Application.get_env(:ktsllex, Schemas)

    Application.put_env(:ktsllex, Schemas, http_client: HTTPoisonMock)

    on_exit(fn ->
      Application.put_env(:ktsllex, Schemas, config)
    end)

    Process.register(self(), :current_test)

    :ok
  end

  describe "run/3" do
    test "it makes http post requests as required" do
      # The host that the requests will be made to
      host = "localhost:1234"
      # The schema name that should update the schema with
      schema_name = "schema_name"
      # The location of the schema files to parse
      base_schema_file = "./schemas/test"

      # The schemas are loaded from the above base_schema_file
      # and the keys "namespace" and "connect.name" are updated
      # to the above schema_name
      key_schema =
        Poison.decode!(~s({
          "type": "record",
          "name": "Key",
          "namespace": "schema_name",
          "connect.name": "schema_name.Key"
        }))
        |> Poison.encode!()
        |> Poison.encode!()

      value_schema =
        Poison.decode!(~s({
          "type": "record",
          "name": "Envelope",
          "namespace": "schema_name"
        }))
        |> Poison.encode!()
        |> Poison.encode!()

      headers = [{"Content-Type", "application/json"}]

      # We mock the HTTP post requests above to just return the data
      # provided, so here we can assert the correct [url, body, headers]
      key_result = %{
        url: host <> "/subjects/" <> schema_name <> "-key/versions",
        body: ~s({"schema":) <> key_schema <> "}",
        headers: headers
      }

      value_result = %{
        url: host <> "/subjects/" <> schema_name <> "-value/versions",
        body: ~s({"schema":) <> value_schema <> "}",
        headers: headers
      }

      assert [:ok, :ok] == Schemas.run(host, schema_name, base_schema_file)
      assert_receive ^key_result
      assert_receive ^value_result
      refute_receive _
    end

    test "when the files cannot be found, " do
      host = "localhost:1234"
      schema_name = "schema_name"
      base_schema_file = "./schemas/not-found"

      assert [:error, :error] == Schemas.run(host, schema_name, base_schema_file)
      refute_receive _
    end
  end
end
