use Mix.Config

config :clio, Clio.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [host: System.get_env("HOST"), port: 80],
  cache_static_manifest: "priv/static/manifest.json"

config :clio, Clio.Endpoint, secret_key_base: System.get_env("SECRET_KEY_BASE")
config :clio, Clio.Repo, adapter: Ecto.Adapters.Postgres, url: System.get_env("DATABASE_URL"), size: 20

config :logger, level: :info
