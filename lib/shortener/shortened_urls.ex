defmodule Shortener.ShortenedURLs do
  @moduledoc """
  Functions for dealing with the ShortenedURL resource
  """

  import Ecto.Query
  alias Shortener.Repo
  alias Shortener.ShortenedURLs.ShortenedURL

  @spec new :: Ecto.Changeset.t()
  def new do
    ShortenedURL.changeset(%ShortenedURL{})
  end

  @spec create(ShortenedURL.url()) :: {:ok, ShortenedURL.t()} | {:error, Ecto.Changeset.t()}
  def create(url) do
    %ShortenedURL{}
    |> ShortenedURL.changeset(%{url: url})
    |> Repo.insert()
  end

  @spec find(ShortenedURL.slug()) :: {:ok, ShortenedURL.t()} | {:error, :not_found}
  def find(slug) do
    query = from su in ShortenedURL, where: su.slug == ^slug

    case Repo.one(query) do
      nil -> {:error, :not_found}
      shortened_url -> {:ok, shortened_url}
    end
  end
end
