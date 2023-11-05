defmodule UnderworkWeb.SetupLive do
  use UnderworkWeb, :live_view

  alias Underwork.Cycles
  alias Underwork.Cycles.Session

  def mount(_params, _session, socket) do
    session = Cycles.current_session_for_user()
    target_cycles = session.target_cycles
    start_at = session.start_at || nearest_10_minutes(DateTime.utc_now())

    socket =
      socket
      |> assign(:session, session)
      |> assign(:target_cycles, target_cycles)
      |> assign(:start_at, start_at)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <:subtitle>Use this form to manage session records in your database.</:subtitle>
      </.header>

      <form id="session-form" phx-submit="save">
        <div>
          <label>Cycles</label>
          <.button type="button" phx-click="decrement_cycles" phx-disable={at_min(@target_cycles)}>
            -
          </.button>
          <span><%= @target_cycles %></span>
          <.button type="button" phx-click="increment_cycles" phx-disable={at_max(@target_cycles)}>
            +
          </.button>
          <span><%= format_session_duration(@target_cycles) %></span>
        </div>
        <div>
          <label>Start at</label>
          <.button type="button" phx-click="decrement_start">-</.button>
          <.local_time id="session-at" time={@start_at} />
          <.button type="button" phx-click="increment_start">+</.button>
          <.local_time id="session-end" time={session_end(@start_at, @target_cycles)} />
        </div>
          <.button phx-disable-with="Saving...">Save Session</.button>
      </form>
    </div>
    """
  end

  def handle_event("increment_cycles", _, socket) do
    new_cycles = min(socket.assigns.target_cycles + 1, 18)

    {:noreply, assign(socket, :target_cycles, new_cycles)}
  end

  def handle_event("decrement_cycles", _, socket) do
    new_cycles = max(socket.assigns.target_cycles - 1, 2)

    {:noreply, assign(socket, :target_cycles, new_cycles)}
  end

  def handle_event("increment_start", _, socket) do
    new_start = DateTime.add(socket.assigns.start_at, 5 * 60, :second)

    {:noreply, assign(socket, :start_at, new_start)}
  end

  def handle_event("decrement_start", _, socket) do
    new_start = DateTime.add(socket.assigns.start_at, -5 * 60, :second)

    {:noreply, assign(socket, :start_at, new_start)}
  end

  def handle_event("save", _, socket) do
    session_params = %{target_cycles: socket.assigns.target_cycles, start_at: socket.assigns.start_at}
    case Cycles.configure_session(socket.assigns.session, session_params) do
      {:ok, _session} ->
        {:noreply,
         socket
         |> put_flash(:info, "Session updated successfully")
         |> push_navigate(to: ~p"/cycles")}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply, put_flash(socket, :error, "An unexpected error happened")}
    end
  end

  defp at_max(target_cycles) do
    target_cycles == Session.max_cycles
  end

  defp at_min(target_cycles) do
    target_cycles == Session.min_cycles
  end

  defp nearest_10_minutes(date_time) do
    seconds = DateTime.to_unix(date_time)
    remainder = rem(seconds, 600)

    rounded_seconds =
      if remainder < 300, do: seconds - remainder, else: seconds + (600 - remainder)

    DateTime.from_unix!(rounded_seconds)
  end

  defp format_session_duration(target_cycles) do
     total_minutes = target_cycles * 40
     hours = div(total_minutes, 60)
     minutes = rem(total_minutes, 60)

     cond do
       hours == 0 -> "#{minutes} mins"
       minutes == 0 -> "#{hours} hours"
       true -> "#{hours} hours, #{minutes} mins"
     end
  end

  defp session_end(start_at, target_cycles) do
    DateTime.add(start_at, target_cycles * 40 * 60, :second)
  end
end
