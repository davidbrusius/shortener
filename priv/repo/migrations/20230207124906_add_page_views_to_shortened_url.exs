defmodule Shortener.Repo.Migrations.AddPageViewsToShortenedURL do
  use Ecto.Migration

  def change do
    alter table(:shortened_urls) do
      add :page_views, :integer, null: false, default: 0
    end
  end
end
