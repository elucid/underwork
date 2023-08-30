{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.erlang
    pkgs.elixir
    pkgs.postgresql
    pkgs.inotify-tools
  ];

  shellHook = ''
    export PGUSER=uw
    export PGHOST=localhost
    export PGPORT=3254
    export PGDATABASE=underwear-dev
    export PGPASSWORD=uw
    export TZ=UTC
  '';
}
