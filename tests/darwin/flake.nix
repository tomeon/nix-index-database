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
            set -eu

            if ! toplevel="$(${pkgs.gitMinimal}/bin/git rev-parse --show-toplevel --path-format=absolute 2>/dev/null)" || [[ -z "''${toplevel:-}" ]]; then
              toplevel="$(${pkgs.coreutils}/bin/readlink -f "''${PWD:-$(pwd -P)}/../..")"
            fi

            nixpkgs_url="$(
                ${pkgs.nix}/bin/nix flake metadata "$toplevel" --json \
              | ${pkgs.jq}/bin/jq --raw-output '.locks.nodes.nixpkgs.locked | "\(.type):\(.owner)/\(.repo)/\(.rev)"'
            )"

            # Otherwise:
            # > error: Unexpected files in /etc, aborting activation
            # > The following files have unrecognized content and would be overwritten:
            # >   /etc/nix/nix.conf
            # > Please check there is nothing critical in these files, rename them by adding .before-nix-darwin to the end, and then try again.
            sudo mv -f /etc/nix/nix.conf{,.before-nix-darwin} || :

            ${nix-darwin.packages.${system}.darwin-rebuild}/bin/darwin-rebuild \
              --override-input nix-index-database "$toplevel" \
              --override-input nixpkgs "$nixpkgs_url" \
              -L \
              --flake '.#${system}' \
              switch

            # Source this file to ensure `nix-locate` available.
            # Disable errexit and nounset since `/etc/static/bashrc` is not
            # compatible with "strict mode".
            set +eu
            source /etc/static/bashrc || :
            set -eu

            if (( "$#" < 1 )); then
              set -- "''${BASH:-bash}" ${../nix-locate-rg-exe}
            fi

            "$@"
          '';
        });

      darwinConfigurations = lib.genAttrs testSystems (system:
        nix-darwin.lib.darwinSystem {
          modules = [
            nix-index-database.darwinModules.nix-index

            {
              networking.hostName = "nix-index-darwin-test";
              nixpkgs.hostPlatform = system;

              # Without this, `nix-darwin` carps:
              # > error: The daemon is not enabled but this is a multi-user install, aborting activation
              # > Enable the nix-daemon service:
              # >     services.nix-daemon.enable = true;
              services.nix-daemon.enable = true;
            }
          ];
        });
    };
}
