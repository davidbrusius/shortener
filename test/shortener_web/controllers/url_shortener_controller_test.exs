defmodule ShortenerWeb.URLShortenerControllerTest do
  use ShortenerWeb.ConnCase, async: true

  describe "index" do
    test "displays the root page with the url shortener form", %{conn: conn} do
      conn = get(conn, Routes.url_shortener_path(conn, :index))

      response = html_response(conn, 200)

      assert response =~ "Shortener"
      assert response =~ "URL shortening made easy"

      html = Floki.parse_document!(response)
      [form] = Floki.find(html, "form.url-shortener")

      assert Floki.text(form) =~ "Shorten"
    end
  end

  describe "create" do
    @tag slug_stub: "JgKAwLDcln"
    test "creates a shortened url for the given url", %{conn: conn} do
      url = "https://www.test.com?param1=value"

      conn = post(conn, Routes.url_shortener_path(conn, :create, shortened_url: [url: url]))
      redirect_path = redirected_to(conn)

      assert redirect_path == Routes.shortened_path(conn, :show, "JgKAwLDcln")

      conn = get(conn, redirect_path)
      html = html_response(conn, 200) |> Floki.parse_document!() |> Floki.text()

      assert html =~ "Successfully shortened URL"
    end

    test "fails if the given url is invalid", %{conn: conn} do
      url = "invalid-url"

      conn = post(conn, Routes.url_shortener_path(conn, :create, shortened_url: [url: url]))

      response = html_response(conn, 422)

      assert response =~ "URL is missing a scheme - valid schemes http, https"
    end
  end

  describe "show" do
    @tag slug_stub: "JgKAwLDcln"
    test "redirects the user to the shortened url", %{conn: conn} do
      shortened_url = fixture(:shortened_url)

      conn = get(conn, Routes.url_shortener_path(conn, :show, shortened_url.slug))

      assert redirected_to(conn) == shortened_url.url
    end

    test "redirects to root path when shortened url does not exist", %{conn: conn} do
      slug = "not-found"

      conn = get(conn, Routes.url_shortener_path(conn, :show, slug))
      redirect_path = redirected_to(conn)

      assert redirect_path == Routes.url_shortener_path(conn, :index)

      conn = get(conn, redirect_path)
      html = html_response(conn, 200) |> Floki.parse_document!() |> Floki.text()

      assert html =~ "Unable to find shortened url for 'not-found' slug"
    end
  end
end
