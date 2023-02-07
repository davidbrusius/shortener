defmodule ShortenerWeb.ShortenedControllerTest do
  use ShortenerWeb.ConnCase, async: true

  describe "show" do
    setup :stub_slug_generation!

    test "displays the shortened url page", %{conn: conn} do
      shortened_url = fixture(:shortened_url)

      conn = get(conn, Routes.shortened_path(conn, :show, shortened_url.slug))

      response = html_response(conn, 200)

      assert response =~ "Successfully shortened URL"
      assert response =~ "Your Shortened URL is:"

      html = Floki.parse_document!(response)
      [link] = Floki.find(html, "a.shortened-url")

      assert Floki.text(link) == "http://localhost:4002/AQIDBAUGBw"
    end

    test "redirects to root path when shortened url does not exist", %{conn: conn} do
      slug = "not-found"

      conn = get(conn, Routes.shortened_path(conn, :show, slug))
      redirect_path = redirected_to(conn)

      assert redirect_path == Routes.url_shortener_path(conn, :index)

      conn = get(conn, redirect_path)
      html = html_response(conn, 200) |> Floki.parse_document!() |> Floki.text()

      assert html =~ "Unable to find shortened url for 'not-found' slug"
    end
  end
end
