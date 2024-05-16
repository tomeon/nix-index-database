{
  description = "nix-index database";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;

      systems = lib.attrNames self.legacyPackages;
      testSystems = [ "x86_64-linux" "aarch64-linux" ];

      databases = import ./packages.nix;

      # From `hercules-ci/flake-parts`:
      # https://github.com/hercules-ci/flake-parts/blob/e5d10a24b66c3ea8f150e47dfdb0416ab7c3390e/lib.nix#L216-L223
      # Preserves the module location while permitting the use of
      # "static"/"constructor" arguments (arguments that are not provided by
      # the module system).
      importApply = modulePath: staticArgs:
        lib.setDefaultModuleLocation modulePath (import modulePath staticArgs);

      importWithDatabases = lib.flip importApply { inherit databases; };

      mkPackages = pkgs: {
        nix-index-with-db =
          pkgs.callPackage ./nix-index-wrapper.nix {
            nix-index-database = databases.${pkgs.stdenv.system}.database;
          };
        comma-with-db =
          pkgs.callPackage ./comma-wrapper.nix {
            nix-index-database = databases.${pkgs.stdenv.system}.database;
          };
      };
    in
    {
      packages = lib.genAttrs systems (system:
        (mkPackages nixpkgs.legacyPackages.${system}) // {
          default = self.packages.${system}.nix-index-with-db;
        }
      );

      legacyPackages = import ./packages.nix;

      overlays.nix-index = final: prev: mkPackages final;

      darwinModules.nix-index = {
        imports = [ (importWithDatabases ./darwin-module.nix) ];
      };

      hmModules.nix-index = {
        imports = [ (importWithDatabases ./home-manager-module.nix) ];
      };

      nixosModules.nix-index = {
        imports = [ (importWithDatabases ./nixos-module.nix) ];
      };

      checks = lib.genAttrs testSystems (system:
        import ./tests.nix {
          inherit self system nixpkgs;
        }
      );
    };
}
