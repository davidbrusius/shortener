defmodule ShortenerWeb.URLShortenerController do
  use ShortenerWeb, :controller
  alias Shortener.ShortenedURLs

  def index(conn, _params) do
    changeset = ShortenedURLs.new()
    render(conn, "index.html", changeset: changeset)
  end

  def create(conn, params) do
    case ShortenedURLs.create(params["shortened_url"]["url"]) do
      {:ok, shortened_url} ->
        redirect(conn, to: Routes.shortened_path(conn, :show, shortened_url.slug))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("index.html", changeset: changeset)
    end
  end

  def show(conn, %{"slug" => slug}) do
    case ShortenedURLs.find(slug) do
      {:ok, shortened_url} ->
        redirect(conn, external: shortened_url.url)

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Unable to find shortened url for '#{slug}' slug")
        |> redirect(to: Routes.url_shortener_path(conn, :index))
    end
  end
end
