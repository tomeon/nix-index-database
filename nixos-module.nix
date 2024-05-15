{ databases }:

{ config, lib, pkgs, ... }:

let
  common = import ./common.nix { inherit config lib pkgs databases; };
in

{
  inherit (common) options;

  config = lib.mkMerge [
    common.config

    {
      programs.nix-index.enable = lib.mkDefault true;
      programs.nix-index.package = lib.mkDefault common.packages.nix-index-with-db;
      environment.systemPackages = lib.optional config.programs.nix-index-database.comma.enable common.packages.comma-with-db;
    }
  ];
}
