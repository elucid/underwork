defmodule Underwear.Repo do
  use Ecto.Repo,
    otp_app: :underwear,
    adapter: Ecto.Adapters.Postgres
end
