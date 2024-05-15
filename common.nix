{ config, pkgs, lib, databases, ... }:

let
  inherit (lib) mkOption types;

  databaseType = types.submodule ({ name, config, ... }: {
    freeformType = types.anything;

    options = {
      name = mkOption {
        type = types.str;
        readOnly = true;
        default = name;
        description = ''
          Name to associate with this `nix-index-database` database package.
        '';
      };

      platform = mkOption {
        type = types.either types.str types.attrs;
        apply = lib.systems.elaborate;
        readOnly = true;
        default = config.name;
        example = "x86_64-linux";
        description = ''
          The platform corresponding to this `nix-index-database` database
          package.
        '';
      };

      database = mkOption {
        type = types.package;
        description = ''
          `nix-index-database` database package.
        '';
      };
    };
  });
in

{
  packages = {
    nix-index-with-db = pkgs.callPackage ./nix-index-wrapper.nix {
      nix-index-database = config.programs.nix-index-database.databases.${pkgs.stdenv.system}.database;
    };
    comma-with-db = pkgs.callPackage ./comma-wrapper.nix {
      nix-index-database = config.programs.nix-index-database.databases.${pkgs.stdenv.system}.database;
    };
  };

  options = {
    programs.nix-index-database = {
      comma.enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to wrap comma with nix-index-database and put it in the PATH.";
      };

      databases = mkOption {
        type = types.attrsOf databaseType;
        default = { };
        description = ''
          Attribute set mapping system strings to `nix-index-database` database
          packages for the system in question.
        '';
      };
    };
  };

  config = {
    programs.nix-index-database = {
      inherit databases;
    };
  };
}
