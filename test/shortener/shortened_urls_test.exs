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
    @tag slug_stub: "TESTSLUG"
    test "creates a shortened url for the given url" do
      url = "https://www.test.com?param1=value"

      {:ok, shortened_url} = ShortenedURLs.create(url)

      assert %ShortenedURL{slug: "TESTSLUG", url: ^url} = shortened_url
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
    @tag slug_stub: "TESTSLUG"
    test "returns the shortened url" do
      url = "https://www.test.com"
      fixture(:shortened_url, %{url: url})

      {:ok, shortened_url} = ShortenedURLs.find("TESTSLUG")

      assert %ShortenedURL{slug: "TESTSLUG", url: ^url} = shortened_url
    end

    test "returns an error when shortened url is not found" do
      assert {:error, :not_found} == ShortenedURLs.find("not-found")
    end
  end

  describe "paginated_list/1" do
    @tag slug_stub: "TESTSLUG"
    test "returns a paginated list of shortened urls" do
      url = "https://www.test.com"
      fixture(:shortened_url, %{url: url})

      assert %Scrivener.Page{
               entries: [%ShortenedURL{url: ^url}],
               total_entries: 1,
               total_pages: 1
             } = ShortenedURLs.paginated_list(page: 1)
    end
  end

  describe "track_page_view/1" do
    test "calls the StartServer GenServer to track the page view" do
      assert :ok == ShortenedURLs.track_page_view("TESTSLUG")
    end
  end

  describe "persist_page_views/1" do
    @tag slug_stub: "TESTSLUG"
    test "persists page views for each slug" do
      shortened_url = fixture(:shortened_url)

      page_views_by_slug = %{"TESTSLUG" => 10}
      ShortenedURLs.persist_page_views(page_views_by_slug)

      shortened_url = Repo.reload(shortened_url)
      assert 10 == shortened_url.page_views
    end

    @tag slug_stub: "TESTSLUG"
    test "increments current page views values" do
      shortened_url = fixture(:shortened_url, %{page_views: 50})

      page_views_by_slug = %{"TESTSLUG" => 25}
      ShortenedURLs.persist_page_views(page_views_by_slug)

      shortened_url = Repo.reload(shortened_url)
      assert 75 == shortened_url.page_views
    end
  end
end
