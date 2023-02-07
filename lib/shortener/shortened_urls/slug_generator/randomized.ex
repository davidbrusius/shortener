defmodule Shortener.ShortenedURLs.SlugGenerator.Randomized do
  @moduledoc """
  Randomized slug generation implementation
  """
  @behaviour Shortener.ShortenedURLs.SlugGenerator

  @impl true
  def generate(slug_size) do
    slug_size
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, slug_size)
  end
end
