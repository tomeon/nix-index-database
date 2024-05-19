{
  description = "nix-index database Darwin tests";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, nix-index-database, ... }:
    let
      inherit (nixpkgs) lib;

      testSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
    in
    {
      packages = lib.genAttrs testSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          run-darwin-test = pkgs.writers.writeBashBin "nix-index-database-run-darwin-test" ''
            set -x

            if ! toplevel="$(${pkgs.git}/bin/git rev-parse --show-toplevel --path-format=absolute 2>/dev/null)" || [[ -z "''${toplevel:-}" ]]; then
              toplevel="$(${pkgs.coreutils}/bin/readlink -f "''${PWD:-$(pwd -P)}/../..")"
            fi

            nixpkgs_url="$(
                ${pkgs.nix}/bin/nix flake metadata "$toplevel" --json \
              | ${pkgs.jq}/bin/jq --raw-output '.locks.nodes.nixpkgs.locked | "\(.type):\(.owner)/\(.repo)/\(.rev)"'
            )"

            ${nix-darwin.packages.${system}.darwin-rebuild}/bin/darwin-rebuild \
              --override-input nix-index-database "$toplevel" \
              --override-input nixpkgs "$nixpkgs_url" \
              -L \
              '.#${system}'

            if (( "$#" < 1 )); then
              set -- "''${BASH:-bash}" -c 'nix-locate --top-level --whole-name --at-root /bin/rg | cut -d" " -f1 | grep -F "ripgrep.out"'
            fi

            exec "$@"
          '';
        });

      darwinConfigurations = lib.genAttrs testSystems (system:
        nix-darwin.lib.darwinSystem {
          modules = [
            nix-index-database.darwinModules.nix-index-database

            {
              networking.hostName = "nix-index-darwin-test";
              nixpkgs.hostPlatform = system;
              programs.command-not-found.enable = false;
            }
          ];
        });
    };
}
