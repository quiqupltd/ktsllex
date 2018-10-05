# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

config :ktsllex, Ktsllex.Schemas, http_client: HTTPoison
config :ktsllex, Ktsllex.Topics, http_client: HTTPoison

config :ktsllex,
  # Should it run the migration when called? Default: false
  run_migrations: false,
  schema_registry_host: {:system, "AVLIZER_CONFLUENT_SCHEMAREGISTRY_URL", "http://localhost:8081"},
  # Reads the yaml schema file from :
  base_path: {:system, "KAFKA_SCHEMA_BASE_PATH", "./schemas"},
  schema_name: {:system, "KAFKA_SCHEMA_NAME", "schema_name"},
  app_name: :ktsllex,
  lenses_host: {:system, "LENSES_HOST", "http://localhost:3030"},
  lenses_user: {:system, "LENSES_USER", "admin"},
  lenses_pass: {:system, "LENSES_PASS", "admin"},
  lenses_topic: {:system, "LENSES_TOPIC", "topic_name"}
