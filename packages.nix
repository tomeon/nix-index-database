# this file is autogenerated by .github/workflows/update.yml
{
  x86_64-linux.database = builtins.fetchurl {
    url = "https://github.com/nix-community/nix-index-database/releases/download/2024-04-07-030847/index-x86_64-linux";
    sha256 = "1n6h407h7z5yidc6xnnkdjyf3gqlmxhhirp8sm17d34a0slyxx4z";
  };
  aarch64-linux.database = builtins.fetchurl {
    url = "https://github.com/nix-community/nix-index-database/releases/download/2024-04-07-030847/index-aarch64-linux";
    sha256 = "07h6az9rsbamjsx79m5giv3ia2lzn5b42dy1kmwkm1xc93qp0l6m";
  };
  x86_64-darwin.database = builtins.fetchurl {
    url = "https://github.com/nix-community/nix-index-database/releases/download/2024-04-07-030847/index-x86_64-darwin";
    sha256 = "1xlpl5p0c3c1ych4dpqxmd259d181rcawfrgp0vbykybzx9dsi75";
   };
  aarch64-darwin.database = builtins.fetchurl {
    url = "https://github.com/nix-community/nix-index-database/releases/download/2024-04-07-030847/index-aarch64-darwin";
    sha256 = "11dmj7d95ddghb1gjpr76xrx8z36ific4r17zlv4r8dv0q1zdkiz";
  };
}
