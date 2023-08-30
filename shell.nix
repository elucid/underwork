{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.erlang
    pkgs.elixir
    pkgs.postgresql
    pkgs.inotify-tools
  ];

  shellHook = ''
    export PGUSER=postgres
    export PGPASSWORD=postgres
    export PGHOST=localhost
    export PGPORT=3254
    export PGDATABASE=underwork_dev
    export TZ=UTC
  '';
}
