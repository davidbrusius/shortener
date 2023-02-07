defmodule Shortener.Fixtures do
  alias Shortener.Repo
  alias Shortener.ShortenedURLs.ShortenedURL

  def fixture(:shortened_url, attrs \\ %{}) do
    attrs = Map.merge(%{url: "https://www.test.com?param1=value"}, attrs)
    Repo.insert!(ShortenedURL.changeset(%ShortenedURL{}, attrs))
  end
end
