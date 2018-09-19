defmodule Ktsllex.LoginTest do
  use ExUnit.Case, async: false

  alias Ktsllex.Login, as: Subject

  defmodule HTTPoisonMock do
    def post("localhost:1234/api/login", body, headers) do
      send(:current_test, %{login_body: body, login_headers: headers})

      case (body |> Poison.decode!())["password"] do
        "correct" ->
          "mock_token" |> :zlib.gzip()
          |> mock_http_poison_response(200, [{"Content-Encoding", "gzip"}])

        "wrong" ->
          "CredentialsRejected" |> mock_http_poison_response(401)
      end
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

    Application.put_env(:ktsllex, Subject, http_client: HTTPoisonMock, login: LoginMock)

    on_exit(fn ->
      Application.put_env(:ktsllex, Subject, config)
    end)

    Process.register(self(), :current_test)

    :ok
  end

  describe "get_token/3" do
    test "with correct credentials creates http post requests as required and returns the token" do
      host = "localhost:1234"
      user = "abc"
      pass = "correct"
      assert "mock_token" == Subject.get_token(host, user, pass)

      login_body = ~s({"user":"abc","password":"correct"})
      login_headers = [{"Content-Type", "application/json"}]

      assert_receive %{login_body: ^login_body, login_headers: ^login_headers}
    end

    test "with incorrect credentials creates http post requests as required and returns :error" do
      host = "localhost:1234"
      user = "abc"
      pass = "wrong"
      assert :error == Subject.get_token(host, user, pass)

      login_body = ~s({"user":"abc","password":"wrong"})
      login_headers = [{"Content-Type", "application/json"}]

      assert_receive %{login_body: ^login_body, login_headers: ^login_headers}
    end
  end
end
