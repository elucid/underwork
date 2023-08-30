let sources = import ./nix/sources.nix;
in with import sources.nixpkgs { };
let inputs = [ erlang elixir postgresql nixfmt ];
in mkShell {
  buildInputs = if stdenv.isDarwin then
    inputs ++ [ pkgs.darwin.apple_sdk.frameworks.CoreServices ]
  else
    inputs ++ [ inotify-tools ];

  shellHook = ''
    export PGUSER=postgres
    export PGPASSWORD=postgres
    export PGHOST=localhost
    export PGPORT=3254
    export PGDATABASE=underwork_dev
    export TZ=UTC
  '';
}
