defmodule Ktsllex.ConfigTest do
  use ExUnit.Case, async: false

  alias Ktsllex.Config, as: Subject

  defmodule HTTPoisonMock do
    def get(url, headers) do
      send(:current_test, %{url: url, headers: headers})

      %{"compatibility" => "BACKWARD"}
      |> Poison.encode!()
      |> mock_http_poison_response(200)
    end

    def put(url, body, headers) do
      send(:current_test, %{url: url, body: body, headers: headers})

      %{"compatibility" => "BACKWARD"}
      |> Poison.encode!()
      |> mock_http_poison_response(200)
    end

    defp mock_http_poison_response(body, status_code, headers \\ []) do
      {:ok,
       %HTTPoison.Response{
         body: body,
         headers: headers,
         status_code: status_code
       }}
    end
  end

  setup do
    config = Application.get_env(:ktsllex, Subject)

    Application.put_env(:ktsllex, Subject, http_client: HTTPoisonMock)

    on_exit(fn ->
      Application.put_env(:ktsllex, Subject, config)
    end)

    Process.register(self(), :current_test)

    :ok
  end

  describe "get/2" do
    test "with default subject, it creates http post requests as required" do
      host = "http://schemaregistry:1234"

      assert %{"compatibility" => "BACKWARD"} == Subject.get(host)

      url = "http://schemaregistry:1234/config/"
      headers = [{"Content-Type", "application/json"}]

      assert_receive %{url: ^url, headers: ^headers}
    end

    test "with a provided subject, it creates http post requests as required" do
      host = "http://schemaregistry:1234"
      subject = "my_subject"

      assert %{"compatibility" => "BACKWARD"} == Subject.get(host, subject)

      url = "http://schemaregistry:1234/config/" <> subject
      headers = [{"Content-Type", "application/json"}]

      assert_receive %{url: ^url, headers: ^headers}
    end
  end

  describe "set/3" do
    test "with default subject, it creates http post requests as required" do
      host = "http://schemaregistry:1234"
      compatibility = "BACKWARD"

      assert %{"compatibility" => "BACKWARD"} == Subject.set(host, compatibility)

      url = "http://schemaregistry:1234/config/"
      body = %{"compatibility" => compatibility} |> Poison.encode!()
      headers = [{"Content-Type", "application/json"}]

      assert_receive %{url: ^url, body: ^body, headers: ^headers}
    end

    test "with a provided subject, it creates http post requests as required" do
      host = "http://schemaregistry:1234"
      compatibility = "BACKWARD"
      subject = "my_subject"

      assert %{"compatibility" => "BACKWARD"} == Subject.set(host, compatibility, subject)

      url = "http://schemaregistry:1234/config/" <> subject
      body = %{"compatibility" => compatibility} |> Poison.encode!()
      headers = [{"Content-Type", "application/json"}]

      assert_receive %{url: ^url, body: ^body, headers: ^headers}
    end
  end
end
