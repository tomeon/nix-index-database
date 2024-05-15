{ config, lib, pkgs, databases, ... }:

let
  common = import ./common.nix { inherit lib pkgs databases; };
in

{
  inherit (common) options;

  config = {
    programs.nix-index.enable = lib.mkDefault true;
    programs.nix-index.package = lib.mkDefault common.packages.nix-index-with-db;
    environment.systemPackages = lib.optional config.programs.nix-index-database.comma.enable common.packages.comma-with-db;
  };
}
