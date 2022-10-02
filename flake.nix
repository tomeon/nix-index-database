# this file is autogenerated by .github/workflows/update.yml
{
  description = "nix-index database";
  outputs = _:
    {
      legacyPackages.x86_64-linux.database = builtins.fetchurl {
        url = "https://github.com/Mic92/nix-index-database/releases/download/2022-10-02/index-x86_64-linux";
        sha256 = "0dxkkhn3ww28dzkrz0gv0f41xcbib8viwnk78bavq1559yr127ih";
      };
      legacyPackages.x86_64-darwin.database = builtins.fetchurl {
        url = "https://github.com/Mic92/nix-index-database/releases/download/2022-10-02/index-x86_64-darwin";
        sha256 = "1g66k8k3w6sh4icl57dmysr4kpi12hp4j3zvrfa8www8p38wj4aw";
      };
    };
}
