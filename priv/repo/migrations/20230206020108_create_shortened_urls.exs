defmodule Shortener.Repo.Migrations.CreateShortenedURLs do
  use Ecto.Migration

  def change do
    create table(:shortened_urls) do
      add :slug, :string, null: false
      add :url, :text, null: false

      timestamps()
    end

    create index(:shortened_urls, [:slug], unique: true)
  end
end
