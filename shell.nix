{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.erlang
    pkgs.elixir
    pkgs.postgresql
    pkgs.inotify-tools
  ];

  shellHook = ''
  '';
}
