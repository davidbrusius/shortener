defmodule ShortenerWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use ShortenerWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import ShortenerWeb.ConnCase
      import Shortener.Fixtures
      import Shortener.SlugGeneratorHelper

      alias ShortenerWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint ShortenerWeb.Endpoint
    end
  end

  setup tags do
    Shortener.DataCase.setup_sandbox(tags)
    if tags[:slug_stub], do: Shortener.SlugGeneratorHelper.stub_slug_generation!(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
