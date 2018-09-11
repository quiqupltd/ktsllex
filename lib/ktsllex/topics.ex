defmodule Ktsllex.Topics do
  @moduledoc """
  This sets up the topics as required to run.
  """

  use Confex, otp_app: :ktsllex
  require Logger

  @login_path "/api/login"
  @topic_path "/api/topics"
  @json_content_type {"Content-Type", "application/json"}

  @doc """

  * `host` - LensesUI host, eg http://localhost:3030"
  * `user` - LensesUI username, required to get access token
  * `password` - LensesUI password
  * `topic_name` - Name of the topic to create

  https://lenses.stream/1.1/developers-guide/rest-api/index.html#topic-api

  """
  def run(host, user, password, topic_name, replication \\ 1, partitions \\ 1) do
    Application.ensure_started(:logger)
    Logger.info("#{__MODULE__} host:#{inspect(host)}")

    host
    |> get_token(user, password)
    |> create_topic(host, topic_name, replication, partitions)
  end

  def run_token(host, token, topic_name, replication \\ 1, partitions \\ 1) do
    Application.ensure_started(:logger)
    Logger.info("#{__MODULE__} host:#{inspect(host)}")

    create_topic(token, host, topic_name, replication, partitions)
  end

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
  defp get_token(host, user, password) do
    %{user: user, password: password}
    |> Poison.encode!()
    |> post(host <> @login_path)
    |> extract_body()
    |> decode()
  end

  defp extract_body({:ok, %HTTPoison.Response{body: body, headers: headers}}) do
    case gzipped(headers) do
      true -> :zlib.gunzip(body)
      false -> body
    end
  end

  defp extract_body({:error, %HTTPoison.Error{reason: reason}}) do
    Logger.error("#{__MODULE__} failed:#{inspect(reason)}")
    :error
  end

  defp gzipped(headers) do
    headers
    |> Enum.any?(fn kv ->
      case kv do
        {"Content-Encoding", "gzip"} -> true
        {"Content-Encoding", "x-gzip"} -> true
        _ -> false
      end
    end)
  end

  defp decode("CredentialsRejected"), do: :error
  defp decode(:error), do: :error
  defp decode(body), do: body

  # POST /api/topics
  #
  # export TOKEN=187568a9-79bd-4064-9b6f-b6a682b9512d
  #
  # curl -X POST \
  #   -H "Content-Type:application/json" \
  #   -H "x-kafka-lenses-token:${TOKEN}" \
  #   -d '{"topicName":"topicA", "replication": 1, "partitions": 1, "configs": {}}' \
  #   ${HOST}/api/topics
  #
  # {
  #     "topicName": "topicA",
  #     "replication": 1,
  #     "partitions": 1,
  #     "configs": {
  #         "cleanup.policy": "compact",
  #         "compression.type": "snappy"
  #     }
  # }

  defp create_topic(nil, _host, _topic_name, _replication, _partitions) do
    message = "Failed to get API token, please check username and password"
    Logger.error("#{__MODULE__} #{message}")
    message
  end

  defp create_topic(token, host, topic_name, replication, partitions) do
    extra_headers = {"x-kafka-lenses-token", token}

    %{
      topicName: topic_name,
      replication: replication,
      partitions: partitions,
      configs: %{}
    }
    |> Poison.encode!()
    |> post(host <> @topic_path, [extra_headers])
    |> extract_body()
    |> log_response()
  end

  defp log_response(:error), do: :error

  defp log_response(response) do
    Logger.info("#{__MODULE__} #{inspect(response)}")
    response
  end

  defp post(body, url, extra_headers \\ []) do
    http_client().post(url, body, [@json_content_type] ++ extra_headers)
  end

  defp http_client(), do: config()[:http_client] || HTTPoison
end
