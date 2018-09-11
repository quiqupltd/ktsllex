defmodule Mix.Tasks.CreateSchemas do
  use Mix.Task

  @shortdoc "Creates the Kafka schemas"
  @moduledoc ~S"""
  This is a mix task wrapper to Ktsllex.Schemas, which
  creates Schemas on a Kafka host.

  See Ktsllex.Schemas for more info

  ### Usage
  ```
  $ mix create_schemas --host=localhost:8081 --schema=schema-name --base=./schemas/files
  ```
  """
  def run(args) do
    {options, _, _} =
      OptionParser.parse(
        args,
        strict: [host: :string, schema: :string, base: :string]
      )

    if options[:host] == nil do
      IO.puts("host missing, set --host=<kafka_host>")
      exit({:shutdown, 1})
    end

    if options[:schema] == nil do
      IO.puts("schema missing, set --schema=<schema>")
      exit({:shutdown, 1})
    end

    if options[:base] == nil do
      IO.puts("base missing, set --base=<base>")
      exit({:shutdown, 1})
    end

    HTTPoison.start()
    Ktsllex.Schemas.run(options[:host], options[:schema], options[:base])
  end
end
