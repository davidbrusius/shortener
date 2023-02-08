import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :shortener, Shortener.Repo,
  username: "postgres",
  password: "postgres",
  hostname: System.get_env("POSTGRES_HOST", "db"),
  database: "shortener_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :shortener, ShortenerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "mRcrgjqnTsvda0uwVJyt4oyGzgeyBQq8wF/045q+BLE4W2lkIyxBP31eyxW+Q9O0",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Config slug generator
config :shortener,
  slug_generator: Shortener.ShortenedURLs.SlugGenerator.Mock,
  stats_server_enabled: false
