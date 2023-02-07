defmodule Shortener.ShortenedURLsTest do
  use Shortener.DataCase, async: true
  alias Shortener.ShortenedURLs
  alias Shortener.ShortenedURLs.ShortenedURL

  describe "new/0" do
    test "returns a brand new changeset" do
      changeset = ShortenedURLs.new()

      assert %Ecto.Changeset{data: %ShortenedURLs.ShortenedURL{}} = changeset
    end
  end

  describe "create/1" do
    @tag slug_stub: "TESTSLUGab"
    test "creates a shortened url for the given url" do
      url = "https://www.test.com?param1=value"

      {:ok, shortened_url} = ShortenedURLs.create(url)

      assert %ShortenedURL{slug: "TESTSLUGab", url: ^url} = shortened_url
    end

    test "returns an error for invalid urls" do
      url = "ftp://test.com"
      {:error, changeset} = ShortenedURLs.create(url)
      assert [url: {"invalid scheme ftp - valid schemes http, https", _}] = changeset.errors

      url = "//test.com"
      {:error, changeset} = ShortenedURLs.create(url)
      assert [url: {"is missing a scheme - valid schemes http, https", _}] = changeset.errors

      url = "https://"
      {:error, changeset} = ShortenedURLs.create(url)
      assert [url: {"is missing a host", _}] = changeset.errors

      url = ""
      {:error, changeset} = ShortenedURLs.create(url)
      assert [url: {"can't be blank", _}] = changeset.errors
    end

    test "returns an error when trying to shorten a shortened url" do
      shortener_url = ShortenerWeb.Endpoint.url()

      {:error, changeset} = ShortenedURLs.create(shortener_url)
      assert [url: {"can't be a Shortener URL", _}] = changeset.errors
    end
  end

  describe "find/1" do
    @tag slug_stub: "TESTSLUGab"
    test "returns the shortened url" do
      url = "https://www.test.com"
      fixture(:shortened_url, %{url: "https://www.test.com"})

      {:ok, shortened_url} = ShortenedURLs.find("TESTSLUGab")

      assert %ShortenedURL{slug: "TESTSLUGab", url: ^url} = shortened_url
    end

    test "returns an error when shortened url is not found" do
      assert {:error, :not_found} == ShortenedURLs.find("not-found")
    end
  end
end
