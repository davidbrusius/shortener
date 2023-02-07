defmodule Shortener.SlugGeneratorHelper do
  alias Shortener.ShortenedURLs.SlugGenerator

  def stub_slug_generation!(tags) do
    Mox.stub(SlugGenerator.Mock, :generate, fn _ ->
      Map.get(tags, :slug_stub, "AQIDBAUGBw")
    end)

    :ok
  end
end
