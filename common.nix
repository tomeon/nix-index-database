{ pkgs, lib, databases, ... }:

{
  packages = {
    nix-index-with-db = pkgs.callPackage ./nix-index-wrapper.nix {
      nix-index-database = databases.${pkgs.stdenv.system}.database;
    };
    comma-with-db = pkgs.callPackage ./comma-wrapper.nix {
      nix-index-database = databases.${pkgs.stdenv.system}.database;
    };
  };

  options = {
    programs.nix-index-database.comma.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to wrap comma with nix-index-database and put it in the PATH.";
    };
  };
}
