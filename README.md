# An Ultraworking-style cycles application

To run:

  * run `nix-shell` to start a nix shell containing required deps
  * run `mix setup` to install and setup dependencies
  * run `docker compose up -p` from within `docker/dev` to start the dev database container
  * (first time only) run `mix ecto.create` to create the dev db
  * start web endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
  * visit [`localhost:4000`](http://localhost:4000)
