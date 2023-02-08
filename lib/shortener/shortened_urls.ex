defmodule Shortener.ShortenedURLs do
  @moduledoc """
  Functions for dealing with the ShortenedURL resource
  """

  import Ecto.Query
  alias Shortener.Repo
  alias Shortener.ShortenedURLs.{ShortenedURL, StatsServer}

  @doc """
  Creates a brand new Ecto.Changeset for ShortenedURL.
  """
  @spec new :: Ecto.Changeset.t()
  def new do
    ShortenedURL.changeset(%ShortenedURL{})
  end

  @doc """
  Creates a ShortenedURL for the given url. Validations are performed using
  Ecto and a Changeset is returned in case of errors.
  """
  @spec create(ShortenedURL.url()) :: {:ok, ShortenedURL.t()} | {:error, Ecto.Changeset.t()}
  def create(url) do
    %ShortenedURL{}
    |> ShortenedURL.changeset(%{url: url})
    |> Repo.insert()
  end

  @doc """
  Finds a ShortenedURL for the given slug.
  """
  @spec find(ShortenedURL.slug()) :: {:ok, ShortenedURL.t()} | {:error, :not_found}
  def find(slug) do
    query = from su in ShortenedURL, where: su.slug == ^slug

    case Repo.one(query) do
      nil -> {:error, :not_found}
      shortened_url -> {:ok, shortened_url}
    end
  end

  @doc """
  Paginated lists ShortenedURLs.
  """
  @spec paginated_list(map()) :: Scrivener.Page.t()
  def paginated_list(pagination) do
    Repo.paginate(from(u in ShortenedURL, order_by: [desc: u.id]), pagination)
  end

  @doc """
  Calls the StatsServer to track a page view for the given slug.
  """
  @spec track_page_view(ShortenedURL.slug()) :: :ok
  def track_page_view(slug) do
    StatsServer.track_page_view(slug)
  end

  @doc """
  Persists pages views by slug ensuring performance by grouping slugs with
  same pages views and running Repo update queries asynchronously.
  """
  @spec persist_page_views(map) :: :ok
  def persist_page_views(page_views_by_slug) do
    page_views_by_slug
    |> Enum.group_by(fn {_slug, page_view} -> page_view end, fn {slug, _page_view} -> slug end)
    |> Task.async_stream(&update_page_views(&1), max_concurrency: max_concurrency())
    |> Stream.run()
  end

  defp update_page_views({page_views, slugs}) do
    Repo.update_all(
      from(su in ShortenedURL, where: su.slug in ^slugs),
      inc: [page_views: page_views]
    )
  end

  defp max_concurrency do
    db_pool_size = Application.get_env(:shortener, Repo)[:pool_size]
    div(db_pool_size, 2)
  end
end
