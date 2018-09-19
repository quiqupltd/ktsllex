defmodule Ktsllex.Config do
  @moduledoc """
  This updates the config for schemas
  """

  use Confex, otp_app: :ktsllex

  @config_api_path "/config/"
  @json_content_type {"Content-Type", "application/json"}

  @doc """
  https://docs.confluent.io/current/schema-registry/docs/api.html#get--config-(string-%20subject)

  * `host` : schemaregistry, eg http://localhost:8081
  * `topic_name`

  iex(1)> Ktsllex.Config.get("http://localhost:8081")
  %{"compatibilityLevel" => "BACKWARD"}

  iex(2)> Ktsllex.Config.get("http://localhost:8081", "not-found-subject")
  %{"error_code" => 40401, "message" => "Subject not found."}

  iex(3)> Ktsllex.Config.get("http://localhost:8081", "valid-subject-with-no-compatibility-defined")
  %{"error_code" => 40401, "message" => "Subject not found."}

  iex(4)> Ktsllex.Config.get("http://localhost:8081", "valid-subject-with-compatibility-defined")
  %{"compatibilityLevel" => "BACKWARD"}
  """

  def get(host, subject_name \\ "") do
    host
    |> build_path(subject_name)
    |> do_get()
    |> extract_body()
    |> Poison.decode!()
  end

  @doc """
  Sets the compatibility level for a given subject or globally if no subject provided.

  compatibility (string) – New global compatibility level. Must be one of NONE, FULL, FORWARD, BACKWARD

  ### Examples
  ```
  iex> Ktsllex.Config.set("http://localhost:8081", "INVALID", "schema-subject-value")
  %{
    "error_code" => 42203,
    "message" => "Invalid compatibility level. Valid values are none, backward, forward and full"
  }

  iex> Ktsllex.Config.set("http://localhost:8081", "BACKWARD", "schema-subject-value")
  %{"compatibility" => "BACKWARD"}
  ```
  """

  @spec set(binary(), any(), binary()) :: any()
  def set(host, compatibility, subject_name \\ "") do
    host
    |> build_path(subject_name)
    |> do_put(compatibility)
    |> extract_body()
    |> Poison.decode!()
  end

  defp build_path(host, subject_name), do: host <> @config_api_path <> subject_name

  defp extract_body({:ok, %HTTPoison.Response{body: body}}), do: body

  defp do_get(url), do: http_client().get(url, [@json_content_type])

  defp do_put(url, compatibility) do
    body = %{compatibility: compatibility} |> Poison.encode!()
    http_client().put(url, body, [@json_content_type])
  end

  defp http_client(), do: config()[:http_client] || HTTPoison
end
