defmodule UnderworkWeb.SessionLive.Show do
  use UnderworkWeb, :live_view

  alias Underwork.Cycles

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:session, Cycles.get_session!(id))}
  end

  defp page_title(:show), do: "Show Session"
  defp page_title(:edit), do: "Edit Session"
end
