{ databases }:

{ config, lib, pkgs, ... }:

let
  common = import ./common.nix { inherit config lib pkgs databases; };
in

{
  options = {
    programs.nix-index-database = {
      inherit (common.options.programs.nix-index-database) databases;
    };
  };

  config = lib.mkMerge [
    common.config

    {
      programs.nix-index.enable = true;
      programs.nix-index.package = common.packages.nix-index-with-db;
    }
  ];
}
