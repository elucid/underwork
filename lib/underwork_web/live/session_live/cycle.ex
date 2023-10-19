defmodule UnderworkWeb.SessionLive.Cycle do
  use UnderworkWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
