defmodule Underwork.Cycles do
  @moduledoc """
  The Cycles context.
  """

  import Ecto.Query, warn: false
  alias Underwork.Repo

  alias Underwork.Cycles.Session
  alias Underwork.Cycles.Cycle

  @doc """
  Returns the list of sessions.

  ## Examples

      iex> list_sessions()
      [%Session{}, ...]

  """
  def list_sessions do
    Repo.all(Session)
  end

  @doc """
  Gets a single session.

  Raises `Ecto.NoResultsError` if the Session does not exist.

  ## Examples

      iex> get_session!(123)
      %Session{}

      iex> get_session!(456)
      ** (Ecto.NoResultsError)

  """
  def get_session!(id), do: Repo.get!(Session, id)

  @doc """
  Creates a session.

  ## Examples

      iex> create_session(%{field: value})
      {:ok, %Session{}}

      iex> create_session(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def configure_session(%Session{} = session, attrs) when session.id == nil do
    session
    |> Session.cycles_changeset(attrs)
    |> Repo.insert()
  end

  # TODO: give a better name
  def configure_session(%Session{} = session, attrs) do
    session
    |> Session.cycles_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a session.

  ## Examples

      iex> update_session(session, %{field: new_value})
      {:ok, %Session{}}

      iex> update_session(session, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def plan_session(%Session{} = session, attrs) do
    session
    |> Session.planning_changeset(attrs)
    |> Repo.update()
  end

  def review_session(%Session{} = session, attrs) do
    session
    |> Session.review_changeset(attrs)
    |> Repo.update()
  end

  def plan_cycle(%Cycle{} = cycle, attrs) do
    cycle
    |> Cycle.planning_changeset(attrs)
    |> Repo.update()
  end

  def finish_work(%Cycle{} = cycle) do
    cycle
    |> Cycle.work_changeset()
    |> Repo.update()
  end

  def finish_work(%Session{} = session) do
    session
    |> Session.work_changeset()
    |> Repo.update()
  end

  def review_cycle(%Cycle{} = cycle, attrs) do
    cycle
    |> Cycle.review_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a session.

  ## Examples

      iex> delete_session(session)
      {:ok, %Session{}}

      iex> delete_session(session)
      {:error, %Ecto.Changeset{}}

  """
  def delete_session(%Session{} = session) do
    Repo.delete(session)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking session changes.

  ## Examples

      iex> change_session(session)
      %Ecto.Changeset{data: %Session{}}

  """
  def change_session_plan(%Session{} = session, attrs \\ %{}) do
    Session.planning_changeset(session, attrs)
  end

  def change_session_target(data, attrs \\ %{}) do
    Session.target_changeset(data, attrs)
  end

  def change_session_review(%Session{} = session, attrs \\ %{}) do
    Session.review_changeset(session, attrs)
  end

  def change_cycle_review(cycle_or_changeset, attrs \\ %{}) do
    Cycle.review_changeset(cycle_or_changeset, attrs)
  end

  def change_cycle_plan(cycle_or_changeset, attrs \\ %{}) do
    Cycle.planning_changeset(cycle_or_changeset, attrs)
  end

  def change_cycle_assessment(cycle_or_changeset, attrs \\ %{}) do
    Cycle.assessment_changeset(cycle_or_changeset, attrs)
  end

  def change_cycle_target(cycle_or_changeset, attrs \\ %{}) do
    Cycle.target_changeset(cycle_or_changeset, attrs)
  end

  def change_session_cycles(%Session{} = session, attrs \\ %{}) do
    Session.cycles_changeset(session, attrs)
  end

  alias Underwork.Cycles.Cycle

  @doc """
  Returns the list of cycles.

  ## Examples

      iex> list_cycles()
      [%Cycle{}, ...]

  """
  def list_cycles do
    Repo.all(Cycle)
  end

  @doc """
  Gets a single cycle.

  Raises `Ecto.NoResultsError` if the Cycle does not exist.

  ## Examples

      iex> get_cycle!(123)
      %Cycle{}

      iex> get_cycle!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cycle!(id), do: Repo.get!(Cycle, id)

  @doc """
  Creates a cycle.

  ## Examples

      iex> create_cycle(%{field: value})
      {:ok, %Cycle{}}

      iex> create_cycle(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cycle(attrs \\ %{}) do
    %Cycle{}
    |> Cycle.changeset(attrs)
    |> Repo.insert()
  end

  def new_cycle(attrs \\ %{}) do
    %Cycle{}
    |> Cycle.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cycle.

  ## Examples

      iex> update_cycle(cycle, %{field: new_value})
      {:ok, %Cycle{}}

      iex> update_cycle(cycle, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cycle(%Cycle{} = cycle, attrs) do
    cycle
    |> Cycle.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cycle.

  ## Examples

      iex> delete_cycle(cycle)
      {:ok, %Cycle{}}

      iex> delete_cycle(cycle)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cycle(%Cycle{} = cycle) do
    Repo.delete(cycle)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cycle changes.

  ## Examples

      iex> change_cycle(cycle)
      %Ecto.Changeset{data: %Cycle{}}

  """
  def change_cycle(%Cycle{} = cycle, attrs \\ %{}) do
    Cycle.changeset(cycle, attrs)
  end

  def current_session_for_user() do
    query = from s in Session, where: s.state != "complete", order_by: [desc: s.created_at]

    session = Repo.one(query) || %Session{}
    Repo.preload(session, [cycles: :session], order_by: :created_at)
  end

  def next_cycle(%Session{} = session) do
    session =
       session
       |> Repo.reload()
       |> Repo.preload([cycles: :session], order_by: :number, force: true)

    last_cycle = List.last(session.cycles)
    last_number = last_cycle && last_cycle.number || 0

    cond do
      last_cycle && last_cycle.state != "complete" ->
        # the current cycle is still underway
        last_cycle

      length(session.cycles) < session.target_cycles ->
        # we don't have enough cycles, create a new one
        {:ok, cycle} = new_cycle(%{session_id: session.id, number: last_number + 1})
        Repo.preload(cycle, :session)

      true ->
        # we're all done, so start reviewing
        finish_work(session)

        nil
    end
  end

  def start_at(%Cycle{number: number} = cycle) do
    n = number - 1

    DateTime.add(cycle.session.start_at, n * 40 * 60, :second)
  end

  def end_at(%Cycle{} = cycle) do
    start_at = start_at(cycle)

    DateTime.add(start_at, 30 * 60, :second)
  end
end
