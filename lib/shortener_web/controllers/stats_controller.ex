defmodule ShortenerWeb.StatsController do
  use ShortenerWeb, :controller
  alias Shortener.ShortenedURLs

  plug :limit_params

  def index(conn, params) do
    page = ShortenedURLs.paginated_list(params)

    render(conn, "index.html",
      shortened_urls: page.entries,
      current_page: page.page_number,
      page_size: page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries
    )
  end

  def csv(conn, params) do
    page = ShortenedURLs.paginated_list(params)

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"stats.csv\"")
    |> put_root_layout(false)
    |> render("index.csv", shortened_urls: page.entries)
  end

  @allowed_pagination_params ["page"]
  defp limit_params(conn, _) do
    Map.put(conn, :params, Map.take(conn.params, @allowed_pagination_params))
  end
end
