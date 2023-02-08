defmodule Shortener.Repo do
  use Ecto.Repo, otp_app: :shortener, adapter: Ecto.Adapters.Postgres
  use Scrivener, page_size: 10
end
