defmodule UnderworkWeb.ReviewSessionComponent do
  use UnderworkWeb, :live_component

  alias Underwork.Cycles

  def update(%{session: session} = assigns, socket) do
    changeset = Cycles.change_session_review(session)
    form = to_form(changeset)

    socket =
      socket
      |> assign(:session, session)
      |> assign(:form, form)

    {:ok, socket}
  end

  def handle_event("validate", %{"session" => params}, socket) do
    changes = Map.merge(string_keys(socket.assigns.form.source.changes), params)

    changeset =
      socket.assigns.session
      |> Cycles.change_session_review(changes)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("set_target", %{"target" => target} = params, socket) do
    changes = Map.merge(string_keys(socket.assigns.form.source.changes), params)

    changeset =
      socket.assigns.session
      |> Cycles.change_session_target(changes)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"session" => params}, socket) do
    changes = Map.merge(string_keys(socket.assigns.form.source.changes), params)
    session = socket.assigns.session

    case Cycles.review_session(session, changes) do
      {:ok, _session} ->
        socket =
          socket
          |> put_flash(:info, "YAY")
          |> push_navigate(to: ~p"/session")

        {:noreply, socket}

      {:error, changeset} ->
        socket =
          socket
          |> assign(:form, to_form(changeset))

        {:noreply, socket}
    end
  end

  def target_button(%{value: value, label: label, form: form, "phx-target": phx_target} = assigns) do
    ~H"""
    <.button type="button"
      phx-click="set_target" phx-value-target={value} phx-target={phx_target}
      class={if Phoenix.HTML.Form.input_value(form, :target) == value, do: "bg-zinc-500", else: "bg-zinc-200"}
      phx-prevent-default><%= label %></.button>
    """
  end

  def string_keys(map) do
    map
    |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end)
    |> Enum.into(%{})
  end
end
