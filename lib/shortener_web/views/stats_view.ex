defmodule ShortenerWeb.StatsView do
  use ShortenerWeb, :view
  alias Shortener.ShortenedURLs.ShortenedURL
  alias ShortenerWeb.Router.Helpers, as: Routes

  @fields_to_encode_csv [:shortened_url, :url, :page_views]

  def render("index.csv", assigns) do
    assigns[:shortened_urls]
    |> Enum.map(fn shortened_url ->
      shortened_url
      |> Map.put(:shortened_url, shortened_url_for(shortened_url))
      |> Map.take(@fields_to_encode_csv)
    end)
    |> CSV.encode(headers: @fields_to_encode_csv)
    |> Enum.to_list()
    |> to_string()
  end

  defp shortened_url_for(%ShortenedURL{slug: slug}) do
    Routes.url_shortener_url(ShortenerWeb.Endpoint, :show, slug)
  end
end
