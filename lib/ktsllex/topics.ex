defmodule Ktsllex.Topics do
  @moduledoc """
  This sets up the topics as required to run.
  """

  use Confex, otp_app: :ktsllex
  require Logger
  alias Ktsllex.{Login, Body}

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
    Logger.info(
      "#{__MODULE__} Creating topic on host:#{inspect(host)} with name:#{inspect(topic_name)}"
    )

    host
    |> login().get_token(user, password)
    |> create_topic(host, topic_name, replication, partitions)
  end

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

  defp create_topic(:error, _host, _topic_name, _replication, _partitions) do
    message = "Failed to get API token, please check username and password"
    Logger.error("#{__MODULE__} #{message}")
    message
  end

  defp create_topic(token, host, topic_name, replication, partitions) do
    %{
      topicName: topic_name,
      replication: replication,
      partitions: partitions,
      configs: %{}
    }
    |> Poison.encode!()
    |> post(host <> @topic_path, token)
    |> Body.extract()
    |> log_response()
  end

  defp log_response(:error), do: :error

  defp log_response(response) do
    Logger.info("#{__MODULE__} #{inspect(response)}")
    response
  end

  defp add_token(token), do: [{"x-kafka-lenses-token", token}]

  defp post(body, url, token) do
    http_client().post(url, body, [@json_content_type] ++ add_token(token))
  end

  defp http_client(), do: config()[:http_client] || HTTPoison

  defp login(), do: config()[:login] || Login
end
