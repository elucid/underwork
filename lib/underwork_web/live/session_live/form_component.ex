defmodule UnderworkWeb.SessionLive.FormComponent do
  use UnderworkWeb, :live_component

  alias Underwork.Cycles

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage session records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="session-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:accomplish]} type="text" label="Accomplish" />
        <.input field={@form[:complete]} type="text" label="Complete" />
        <.input field={@form[:distractions]} type="text" label="Distractions" />
        <.input field={@form[:important]} type="text" label="Important" />
        <.input field={@form[:measurable]} type="text" label="Measurable" />
        <.input field={@form[:noteworthy]} type="text" label="Noteworthy" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Session</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{session: session} = assigns, socket) do
    changeset = Cycles.change_session(session)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"session" => session_params}, socket) do
    changeset =
      socket.assigns.session
      |> Cycles.change_session(session_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"session" => session_params}, socket) do
    save_session(socket, socket.assigns.action, session_params)
  end

  defp save_session(socket, :edit, session_params) do
    case Cycles.update_session(socket.assigns.session, session_params) do
      {:ok, session} ->
        notify_parent({:saved, session})

        {:noreply,
         socket
         |> put_flash(:info, "Session updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_session(socket, :new, session_params) do
    case Cycles.create_session(session_params) do
      {:ok, session} ->
        notify_parent({:saved, session})

        {:noreply,
         socket
         |> put_flash(:info, "Session created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
