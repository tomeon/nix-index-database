{ self, system, nixpkgs }:

let
  hostPkgs = nixpkgs.legacyPackages.${system};
in

{
  nixosTest = nixpkgs.lib.nixos.runTest {
    inherit hostPkgs;
    name = "nix-index-nixos-test";
    imports = [{
      nodes =
        let
          common = { pkgs, ... }: {
            programs.command-not-found.enable = false;
            # Point comma at our nixpkgs instance.
            # Passing --nixpkgs-flake instead seems to fail when nix tries to use the network.
            nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
            # Add ripgrep to the store so that comma can find it
            virtualisation.additionalPaths = [ pkgs.ripgrep ];
          };
        in
        {
          node1 = {
            imports = [
              self.nixosModules.nix-index
              common
              {
                programs.nix-index-database.comma.enable = true;
              }
            ];
          };
          node2 = { pkgs, ... }: {
            imports = [
              "${hostPkgs.home-manager.src}/nixos"
              common
              {
                home-manager.users.niu = {
                  imports = [ self.hmModules.nix-index ];
                  home.stateVersion = "24.05";
                  programs.nix-index.symlinkToCacheHome = true;
                  programs.nix-index-database.comma.enable = true;
                };
                users.users.niu.isNormalUser = true;
              }
            ];
          };
        };
      testScript = { nodes, ... }: ''
        import shlex

        def runuser_cmd(user, cmd):
          return f"runuser -c {shlex.quote(cmd)} - {shlex.quote(user)}"

        start_all()

        cmd = " | ".join([
          "nix-locate --top-level --whole-name --at-root '/bin/rg'",
          "cut -d' ' -f1",
          "grep -F 'ripgrep.out'"
        ])

        # Check that nix-locate works
        node1.succeed(cmd)

        # Check that comma works
        node1.fail("rg --help")
        node1.succeed(", rg --help")

        # Check that nix-locate fails for `root`
        node2.fail(cmd)

        # But works for `niu`
        node2.succeed(runuser_cmd("niu", cmd))

        # Check that comma fails for `root`
        node2.fail(", rg --help")

        # But works for `niu`
        node2.fail(runuser_cmd("niu", "rg --help"))
        node2.succeed(runuser_cmd("niu", ", rg --help"))
      '';
    }];
  };
}
