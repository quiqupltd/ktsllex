defmodule Ktsllex.Login do
  @moduledoc """
  Code to get API credentials based on username and password
  """

  use Confex, otp_app: :ktsllex
  require Logger

  alias Ktsllex.Body

  @login_path "/api/login"
  @json_content_type {"Content-Type", "application/json"}

  # POST /api/login
  #
  # HOST="http://localhost:3030"
  # TOKEN=$(curl -X POST -H "Content-Type:application/json" -d '{"user":"admin",  "password":"admin"}' ${HOST}/api/login --compress -s | jq -r .'token')
  # echo $TOKEN
  # version 2.0
  # {
  #     "success": true,
  #     "token": "a1f44cb8-0f37-4b96-828c-57bbd8d4934b",
  #     "user": {
  #         "id": "admin",
  #         "name": "Admin User",
  #         "email": null,
  #         "roles": ["admin", "read", "write", "nodata"]
  #     },
  #     "schemaRegistryDelete": true
  # }
  #
  # version 2.1
  # "a1f44cb8-0f37-4b96-828c-57bbd8d4934b"
  @spec get_token(binary(), any(), any()) :: any()
  def get_token(host, user, password) do
    %{user: user, password: password}
    |> Poison.encode!()
    |> post(host <> @login_path)
    |> Body.extract()
    |> decode()
  end

  defp decode("CredentialsRejected"), do: :error
  defp decode(body), do: body

  defp post(body, url, extra_headers \\ []) do
    http_client().post(url, body, [@json_content_type] ++ extra_headers)
  end

  defp http_client(), do: config()[:http_client] || HTTPoison
end
