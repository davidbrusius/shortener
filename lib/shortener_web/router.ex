defmodule ShortenerWeb.Router do
  use ShortenerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ShortenerWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", ShortenerWeb do
    pipe_through :browser

    resources "/", URLShortenerController, only: [:index, :create, :show], param: "slug"
    resources "/shortened", ShortenedController, only: [:show], param: "slug"
  end
end
