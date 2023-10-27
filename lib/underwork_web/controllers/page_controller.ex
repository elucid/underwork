defmodule UnderworkWeb.PageController do
  use UnderworkWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    redirect(conn, to: ~p"/session")
  end
end
