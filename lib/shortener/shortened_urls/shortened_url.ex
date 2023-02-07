defmodule Shortener.ShortenedURLs.ShortenedURL do
  use Ecto.Schema
  import Ecto.Changeset
  alias Shortener.ShortenedURLs.SlugGenerator

  @type slug :: String.t()
  @type url :: String.t()

  @type t :: %__MODULE__{
          id: non_neg_integer(),
          slug: slug(),
          url: url(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @slug_size 10
  @valid_url_schemes ["http", "https"]

  schema "shortened_urls" do
    field :slug, :string, autogenerate: {SlugGenerator, :generate, [@slug_size]}
    field :url, :string

    timestamps()
  end

  def changeset(shortened_url, attrs \\ %{}) do
    shortened_url
    |> cast(attrs, [:url])
    |> validate_required([:url])
    |> validate_url()
    |> unique_constraint(:slug)
  end

  defp validate_url(changeset) do
    shortener_app_host = ShortenerWeb.Endpoint.host()

    validate_change(changeset, :url, fn :url, url ->
      case URI.parse(url) do
        %URI{scheme: scheme} when scheme in [nil, ""] ->
          [url: "is missing a scheme - valid schemes #{Enum.join(@valid_url_schemes, ", ")}"]

        %URI{host: host} when host in [nil, ""] ->
          [url: "is missing a host"]

        %URI{host: ^shortener_app_host} ->
          [url: "can't be a Shortener URL"]

        %URI{scheme: scheme} when scheme in @valid_url_schemes ->
          []

        %URI{scheme: scheme} ->
          [url: "invalid scheme #{scheme} - valid schemes #{Enum.join(@valid_url_schemes, ", ")}"]

        _ ->
          [url: "is not valid"]
      end
    end)
  end
end
