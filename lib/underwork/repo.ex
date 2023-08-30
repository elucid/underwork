defmodule Underwork.Repo do
  use Ecto.Repo,
    otp_app: :underwork,
    adapter: Ecto.Adapters.Postgres
end
