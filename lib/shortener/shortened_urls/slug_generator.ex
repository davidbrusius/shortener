defmodule Shortener.ShortenedURLs.SlugGenerator do
  @moduledoc """
  Abstract slug generation functions
  """

  alias Shortener.ShortenedURLs.SlugGenerator

  @callback generate(slug_size :: integer()) :: binary()

  def generate(slug_size), do: impl().generate(slug_size)

  defp impl do
    Application.get_env(:shortener, :slug_generator, SlugGenerator.Randomized)
  end
end
