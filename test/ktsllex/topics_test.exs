defmodule Ktsllex.TopicsTest do
  use ExUnit.Case, async: false

  alias Ktsllex.Topics, as: Subject

  defmodule HTTPoisonMock do
    def post("localhost:1234/api/login", body, headers) do
      send(:current_test, %{login_body: body, login_headers: headers})

      case (body |> Poison.decode!())["password"] do
        "correct" ->
          %{token: "mock_token"} |> Poison.encode!() |> mock_http_poison_response(200)

        "wrong" ->
          %{token: nil} |> Poison.encode!() |> mock_http_poison_response(401)
      end
    end

    def post("localhost:1234/api/topics", body, headers) do
      send(:current_test, %{topic_body: body, topic_headers: headers})

      case (body |> Poison.decode!())["topicName"] do
        "topic_name" ->
          mock_http_poison_response("Topic `topic_name` created", 201)

        "fail_topic" ->
          mock_http_poison_response("There was an error creating topic:`fail_topic`", 500)
      end
    end

    defp mock_http_poison_response(body, status_code) do
      {:ok, %HTTPoison.Response{body: body, status_code: status_code}}
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

  describe "run/6" do
    test "it creates http post requests as required" do
      # The host that the requests will be made to
      host = "localhost:1234"
      user = "abc"
      pass = "correct"
      # The topic name that should created
      topic_name = "topic_name"

      assert "Topic `topic_name` created" == Subject.run(host, user, pass, topic_name)

      login_body = ~s({"user":"abc","password":"correct"})
      login_headers = [{"Content-Type", "application/json"}]
      assert_receive %{login_body: ^login_body, login_headers: ^login_headers}

      topic_body = ~s({"topicName":"topic_name","replication":1,"partitions":1,"configs":{}})

      topic_headers = [
        {"Content-Type", "application/json"},
        {"x-kafka-lenses-token", "mock_token"}
      ]

      assert_receive %{topic_body: ^topic_body, topic_headers: ^topic_headers}

      refute_receive _
    end

    test "when the auth details are incorrect, it returns text stating that" do
      host = "localhost:1234"
      user = "abc"
      pass = "wrong"
      topic_name = "topic_name"

      assert "Failed to get API token, please check username and password" ==
               Subject.run(host, user, pass, topic_name)
    end

    test "when the topic creation fails, it returns text stating that" do
      host = "localhost:1234"
      user = "abc"
      pass = "correct"
      topic_name = "fail_topic"

      assert "There was an error creating topic:`fail_topic`" ==
               Subject.run(host, user, pass, topic_name)
    end
  end
end
