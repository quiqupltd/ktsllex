# Ktsllex

[![Build Status](https://travis-ci.org/quiqupltd/ktsllex.svg?branch=master)](https://travis-ci.org/quiqupltd/ktsllex)
[![Package Version](https://img.shields.io/hexpm/v/ktsllex.svg)](https://hex.pm/packages/ktsllex)

Kafka Topic and Schema creator

## Usage

Add `ktsllex` to your `deps` list :
```elixir
 {:ktsllex, "~> 0.0.2"},
```

Run `mix do deps.get, deps.compile`

Now you have access to `create_schemas` and `create_topics` mix tasks, eg:

```bash
$ mix create_schemas --host=localhost:8081 --schema=schema_name --base=./path/to/schemas/json
$ mix create_topics --host=localhost:3030 --user=admin --password=admin --topic=topic_name
```

### `--base`

The path to the schema files is passed into `mix create_schemas` via `--base=./path/to/schemas/json`.

It expects to find two files there, one ending `-key.json` and one `-value.json`.

Example: If this command was used:

```bash
mix create_schemas --base=./schemas/users
```

Then there should be two flies in ./schemas:

* `./schemas-key.json`
* `./schemas-value.json`

### `--schema`

The `-key` and `-value` schemas get updated based on the `schema` parameter

Example: Given this `myschema` command :

```bash
mix create_schemas --schema=myschema
```

And if this is the `schemas-key.json` file :

```json
{
  "type": "record",
  "name": "Key",
  "namespace": "anything",
  "connect.name": "anything.Key"
}
```

Then it would be updated to

```json
{
  "type": "record",
  "name": "Key",
  "namespace": "myschema",
  "connect.name": "myschema.Key"
}
```



## Development

* `mix deps.get`
* `mix test`
