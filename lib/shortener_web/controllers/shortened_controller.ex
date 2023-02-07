defmodule ShortenerWeb.ShortenedController do
  use ShortenerWeb, :controller
  alias Shortener.ShortenedURLs

  def show(conn, %{"slug" => slug}) do
    case ShortenedURLs.find(slug) do
      {:ok, shortened_url} ->
        render(conn, "show.html", shortened_url: shortened_url)

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Unable to find shortened url for '#{slug}' slug")
        |> redirect(to: Routes.url_shortener_path(conn, :index))
    end
  end
end
