# Ktsllex

[![Build Status](https://travis-ci.org/quiqupltd/ktsllex.svg?branch=master)](https://travis-ci.org/quiqupltd/ktsllex)
[![Coverage Status](https://coveralls.io/repos/github/quiqupltd/ktsllex/badge.svg?branch=master)](https://coveralls.io/github/quiqupltd/ktsllex?branch=master)
[![Hex docs](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat-square)](https://hexdocs.pm/ktsllex)
[![Hex Version](http://img.shields.io/hexpm/v/ktsllex.svg?style=flat-square)](https://hex.pm/packages/ktsllex)
[![License](https://img.shields.io/hexpm/l/ktsllex.svg?style=flat-square)](https://github.com/quiqupltd/ktsllex/blob/master/LICENSE.txt)

Kafka Topic and Schema creator

## Setup

Add `ktsllex` to your `deps` list :

```elixir
 {:ktsllex, "~> 0.0.2"},
```

Run `mix do deps.get, deps.compile`

### Auto migrations

To have it run schema migrations at application boot time.

Add `ktsllex` to your app boot sequence. After `logger`, and before any schema reading apps.

```elixir
      extra_applications: [
        :logger,
        ...
        :ktsllex,
        ...
        :event_serializer
```

And update config.exs

```elixir
  config :ktsllex,
    # Should it run the migration when called? Default: false
    run_migrations: false,
    schema_registry_host: {:system, "AVLIZER_CONFLUENT_SCHEMAREGISTRY_URL", "http://localhost:8081"},
    # Reads the yaml schema file from :
    base_path: {:system, "KAFKA_SCHEMA_BASE_PATH", "./schemas"},
    schema_name: {:system, "KAFKA_SCHEMA_NAME", "schema_name"},
    app_name: :app,
    lenses_host: {:system, "LENSES_HOST", "http://localhost:3030"},
    lenses_user: {:system, "LENSES_USER", "admin"},
    lenses_pass: {:system, "LENSES_PASS", "admin"},
    lenses_topic: {:system, "LENSES_TOPIC", "topic_name"}
```

- `base_path` - needs to be relitive to a path that is releasted with your app, eg `priv`

## Usage

You have access to `create_schemas` and `create_topics` mix tasks, eg:

```bash
$ mix create_schemas --host=localhost:8081 --schema=schema_name --base=./path/to/schemas/json
$ mix create_topics --host=localhost:3030 --user=admin --password=admin --topic=topic_name
```

### Options

- `--base`

The path to the schema files is passed into `mix create_schemas` via `--base=./path/to/schemas/json`.

It expects to find a single file there for the schema.

Example: If this command was used:

```bash
mix create_schemas --base=./schemas/users
```

Then there should be a single flie in ./schemas:

- `./schemas.json`

- `--schema`

The schemas get updated based on the `schema` parameter

Example: Given this `myschema` command :

```bash
mix create_schemas --schema=myschema
```

And if this is the `schemas.json` file :

```json
{
  "name": "test",
  "key_avro_schema": {
    "type": "record",
    "name": "Key",
    "namespace": "anything",
    "connect.name": "anything.Key"
  },
  "value_avro_schema": {
    "type": "record",
    "name": "Envelope",
    "namespace": "anything"
  }
}
```

Then it would be updated to

```json
{
  "name": "test",
  "key_avro_schema": {
    "type": "record",
    "name": "Key",
    "namespace": "myschema",
    "connect.name": "myschema.Key"
  },
  "value_avro_schema": {
    "type": "record",
    "name": "Envelope",
    "namespace": "myschema"
  }
}
```

### Compatibility Config

To `get` or `set` compatibility config :

```elixir
# Get global
iex> Ktsllex.Config.get("http://localhost:8081")
%{"compatibilityLevel" => "BACKWARD"}

# Set global
iex> Ktsllex.Config.set("http://localhost:8081", "BACKWARD")
%{"compatibilityLevel" => "BACKWARD"}

# Get for a given topic name
iex> Ktsllex.Config.get("http://localhost:8081", "topic-name")
%{"compatibilityLevel" => "BACKWARD"}

# Set for a given topic name
iex> Ktsllex.Config.set("http://localhost:8081", "BACKWARD", "topic-name")
%{"compatibilityLevel" => "BACKWARD"}
```

If getting a topic that does not have a compatibility set, it will return this:

```elixir
%{"error_code" => 40401, "message" => "Subject not found."}
```

## Development

- `mix deps.get`
- `mix test`

## License

Copyright (c) 2018 Quiqup LTD, MIT License.
See [LICENSE.txt](https://github.com/quiqupltd/ktsllex/blob/master/LICENSE.txt) for further details.
