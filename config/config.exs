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
  # Should it run the migration when called? Default: true
  run_migrations: true,
  schema_registry_host: "http://localhost:8081",
  schema_name: "schema_name",
  # Need to know where the app is to get the path to the schema files
  app_name: :your_otp_app_name,
  base_path: "./schemas/file/location",
  lenses_host: "http://localhost:3030",
  lenses_user: "admin",
  lenses_pass: "admin",
  lenses_topic: "lenses_topic"
