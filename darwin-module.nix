{ databases }:

{ config, lib, pkgs, ... }:

let
  common = import ./common.nix {
    inherit config lib pkgs databases;
    includeCommaOptions = false;
  };
in

{
  inherit (common) options;

  config = lib.mkMerge [
    common.config

    {
      programs.nix-index.enable = true;
      programs.nix-index.package = common.packages.nix-index-with-db;
    }
  ];
}
