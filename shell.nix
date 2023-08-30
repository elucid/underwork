let sources = import ./nix/sources.nix;
in with import sources.nixpkgs { };
let inputs = [ erlang elixir postgresql nixfmt ];
in mkShell {
  buildInputs = if stdenv.isDarwin then inputs else inputs ++ [ inotify-tools ];

  shellHook = ''
    export PGUSER=uw
    export PGHOST=localhost
    export PGPORT=3254
    export PGDATABASE=underwear-dev
    export PGPASSWORD=uw
    export TZ=UTC
  '';
}
