defmodule Underwork.CyclesTest do
  use Underwork.DataCase

  alias Underwork.Cycles

  describe "sessions" do
    alias Underwork.Cycles.Session

    import Underwork.CyclesFixtures

    @invalid_attrs %{accomplish: nil, complete: nil, distractions: nil, important: nil, measurable: nil, noteworthy: nil}

    test "list_sessions/0 returns all sessions" do
      session = session_fixture()
      assert Cycles.list_sessions() == [session]
    end

    test "get_session!/1 returns the session with given id" do
      session = session_fixture()
      assert Cycles.get_session!(session.id) == session
    end

    test "create_session/1 with valid data creates a session" do
      valid_attrs = %{accomplish: "some accomplish", complete: "some complete", distractions: "some distractions", important: "some important", measurable: "some measurable", noteworthy: "some noteworthy"}

      assert {:ok, %Session{} = session} = Cycles.create_session(valid_attrs)
      assert session.accomplish == "some accomplish"
      assert session.complete == "some complete"
      assert session.distractions == "some distractions"
      assert session.important == "some important"
      assert session.measurable == "some measurable"
      assert session.noteworthy == "some noteworthy"
    end

    test "creating workflow for session" do
      valid_attrs = %{accomplish: "some accomplish", complete: "some complete", distractions: "some distractions", important: "some important", measurable: "some measurable", noteworthy: "some noteworthy"}
      assert {:ok, %Session{} = session} = Cycles.create_session(valid_attrs)

      assert {:ok, %{context: %{session: session}}} = ExState.create(session)
    end

    test "create_session/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Cycles.create_session(@invalid_attrs)
    end

    test "update_session/2 with valid data updates the session" do
      session = session_fixture()
      update_attrs = %{accomplish: "some updated accomplish", complete: "some updated complete", distractions: "some updated distractions", important: "some updated important", measurable: "some updated measurable", noteworthy: "some updated noteworthy"}

      assert {:ok, %Session{} = session} = Cycles.update_session(session, update_attrs)
      assert session.accomplish == "some updated accomplish"
      assert session.complete == "some updated complete"
      assert session.distractions == "some updated distractions"
      assert session.important == "some updated important"
      assert session.measurable == "some updated measurable"
      assert session.noteworthy == "some updated noteworthy"
    end

    test "update_session/2 with invalid data returns error changeset" do
      session = session_fixture()
      assert {:error, %Ecto.Changeset{}} = Cycles.update_session(session, @invalid_attrs)
      assert session == Cycles.get_session!(session.id)
    end

    test "delete_session/1 deletes the session" do
      session = session_fixture()
      assert {:ok, %Session{}} = Cycles.delete_session(session)
      assert_raise Ecto.NoResultsError, fn -> Cycles.get_session!(session.id) end
    end

    test "change_session/1 returns a session changeset" do
      session = session_fixture()
      assert %Ecto.Changeset{} = Cycles.change_session(session)
    end
  end
end
