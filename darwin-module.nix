{ lib, pkgs, databases, ... }:

let
  common = import ./common.nix { inherit lib pkgs databases; };
in

{
  programs.nix-index.enable = true;
  programs.nix-index.package = common.packages.nix-index-with-db;
}
