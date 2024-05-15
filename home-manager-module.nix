{ config, lib, pkgs, databases, ... }:

let
  common = import ./common.nix { inherit lib pkgs databases; };
in

{
  options = lib.recursiveUpdate common.options {
    programs.nix-index.symlinkToCacheHome = lib.mkOption {
      type = lib.types.bool;
      default = config.programs.nix-index.enable;
      description = ''
        Whether to symlink the prebuilt nix-index database to the default
        location used by nix-index. Useful for tools like comma.
      '';
    };
  };
  config = {
    programs.nix-index = {
      enable = lib.mkDefault true;
      package = lib.mkDefault common.packages.nix-index-with-db;
    };
    home.packages = lib.optional config.programs.nix-index-database.comma.enable common.packages.comma-with-db;

    home.file."${config.xdg.cacheHome}/nix-index/files" =
      lib.mkIf config.programs.nix-index.symlinkToCacheHome
        { source = databases.${pkgs.stdenv.system}.database; };
  };
}
