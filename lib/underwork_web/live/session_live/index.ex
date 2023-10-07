defmodule UnderworkWeb.SessionLive.Index do
  use UnderworkWeb, :live_view

  alias Underwork.Cycles
  alias Underwork.Cycles.Session

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :sessions, Cycles.list_sessions())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Session")
    |> assign(:session, Cycles.get_session!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Session")
    |> assign(:session, %Session{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Sessions")
    |> assign(:session, nil)
  end

  @impl true
  def handle_info({UnderworkWeb.SessionLive.FormComponent, {:saved, session}}, socket) do
    {:noreply, stream_insert(socket, :sessions, session)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    session = Cycles.get_session!(id)
    {:ok, _} = Cycles.delete_session(session)

    {:noreply, stream_delete(socket, :sessions, session)}
  end
end
