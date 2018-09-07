defmodule Mix.Tasks.CreateTopics do
  use Mix.Task

  @shortdoc "Creates the Kafka topics"
  @moduledoc ~S"""
  This is a mix task wrapper to Ktsllex.Topics, which
  creates Topics on a Kafka host.

  See Ktsllex.Topic for more info

  ### Usage
  ```
  $ mix create_topics --host=localhost:3030 --user=admin --password=password --topic=topic_name
  Topic `topic_name` created
  ```
  """
  def run(args) do
    {options, _, _} =
      OptionParser.parse(
        args,
        strict: [host: :string, user: :string, password: :string, topic: :string]
      )

    if options[:host] == nil do
      IO.puts("host missing, set --host=<kafka_host>")
      exit({:shutdown, 1})
    end

    if options[:user] == nil do
      IO.puts("user missing, set --user=<kafka_user>")
      exit({:shutdown, 1})
    end

    if options[:password] == nil do
      IO.puts("password missing, set --password=<kafka_password>")
      exit({:shutdown, 1})
    end

    if options[:topic] == nil do
      IO.puts("topic missing, set --topic=<topic>")
      exit({:shutdown, 1})
    end

    HTTPoison.start()

    Ktsllex.Topics.run(
      options[:host],
      options[:user],
      options[:password],
      options[:topic]
    )
    |> IO.puts()
  end
end
