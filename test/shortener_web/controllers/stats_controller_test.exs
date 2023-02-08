defmodule ShortenerWeb.StatsControllerTest do
  use ShortenerWeb.ConnCase, async: true
  alias Shortener.ShortenedURLs.SlugGenerator

  describe "index" do
    test "lists shortened urls stats", %{conn: conn} do
      create_shortened_urls()

      conn = get(conn, Routes.stats_path(conn, :index))

      html = html_response(conn, 200) |> Floki.parse_document!()
      [row1, row2] = Floki.find(html, "table tbody tr")
      [pagination] = Floki.find(html, "a.pagination-link")

      assert Floki.text(row1) =~ "http://localhost:4002/EXAMPLESLUG"
      assert Floki.text(row1) =~ "https://example.com"
      assert Floki.text(row1) =~ "30"

      assert Floki.text(row2) =~ "http://localhost:4002/TESTSLUG"
      assert Floki.text(row2) =~ "https://test.com"
      assert Floki.text(row2) =~ "15"

      assert ["/stats?page=1"] = Floki.attribute(pagination, "href")
    end

    test "renders notice when no urls were shortened yet", %{conn: conn} do
      conn = get(conn, Routes.stats_path(conn, :index))

      html = html_response(conn, 200)

      assert html =~ "Ohh! Looks like you have not shortened any URLs yet"
    end
  end

  describe "csv" do
    test "returns a csv with shortened urls data for the given page", %{conn: conn} do
      create_shortened_urls()

      conn = get(conn, Routes.stats_path(conn, :csv))

      csv = response(conn, 200)

      assert """
             shortened_url,url,page_views\r
             http://localhost:4002/EXAMPLESLUG,https://example.com,30\r
             http://localhost:4002/TESTSLUG,https://test.com,15\r
             """ == csv

      assert "text/csv; charset=utf-8" == response_content_type(conn, :csv)
    end
  end

  defp create_shortened_urls do
    Mox.expect(SlugGenerator.Mock, :generate, fn _ -> "TESTSLUG" end)
    Mox.expect(SlugGenerator.Mock, :generate, fn _ -> "EXAMPLESLUG" end)
    fixture(:shortened_url, %{url: "https://test.com", page_views: 15})
    fixture(:shortened_url, %{url: "https://example.com", page_views: 30})
  end
end
