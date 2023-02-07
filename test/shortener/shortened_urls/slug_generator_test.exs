defmodule Shortener.ShortenedURLs.SlugGeneratorTest do
  use ExUnit.Case, async: true
  alias Shortener.ShortenedURLs.SlugGenerator

  describe "generate/1" do
    test "generates a slug with the given size" do
      switch_slug_generator!()

      slug = SlugGenerator.generate(5)
      assert 5 == String.length(slug)

      slug = SlugGenerator.generate(10)
      assert 10 == String.length(slug)
    end
  end

  defp switch_slug_generator! do
    current_generator = Application.get_env(:shortener, :slug_generator)
    Application.put_env(:shortener, :slug_generator, SlugGenerator.Randomized)

    on_exit(fn ->
      Application.put_env(:shortener, :slug_generator, current_generator)
    end)
  end
end
