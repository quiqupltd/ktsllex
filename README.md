# Ktsllex

[![Build Status](https://travis-ci.org/quiqupltd/ktsllex.svg?branch=master)](https://travis-ci.org/quiqupltd/ktsllex)
[![Package Version](https://img.shields.io/hexpm/v/ktsllex.svg)](https://hex.pm/packages/ktsllex)

Kafka Topic and Schema creator

## Usage

Add `ktsllex` to your `deps` list :
```elixir
 {:ktsllex, "~> 0.0.1"},
```

Run `mix deps.get`

Now you have access to `create_schemas` and `create_topics` mix tasks, eg:

```bash
$ mix create_schemas --host=localhost:8081 --schema=schema_name --base=./path/to/schemas/json
$ mix create_topics --host=localhost:3030 --user=admin --password=admin --topic=topic_name
```

## Development

* `mix deps.get`
* `mix test`
