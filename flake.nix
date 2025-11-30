{
  description = "A flake for the AdGuard for Linux CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachSystem
      [
        "x86_64-linux"
        "aarch64-linux"
      ]
      (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          version = "1.1.45";

          adguardCliAsset = {
            baseUrl = "https://github.com/AdguardTeam/AdGuardCLI/releases/download/v${version}-release";

            x86_64-linux = {
              name = "adguard-cli-${version}-linux-x86_64.tar.gz";
              sourceRoot = "adguard-cli-${version}-linux-x86_64";
              sha256 = "sha256-a3A62nzXf75wSpVuiMiRPkwZfMfhWTMQNUeWw12A42s=";
              curlOptsList = [ "-L" ];
            };

            aarch64-linux = {
              name = "adguard-cli-${version}-linux-aarch64.tar.gz";
              sourceRoot = "adguard-cli-${version}-linux-aarch64";
              sha256 = "sha256-ZHxfDvSCZAtgYHimAZdExaH05dXcn0PeS/J7S62NvCE=";
              curlOptsList = [ "-L" ];
            };
          };

          asset = adguardCliAsset.${system} or (throw "Unsupported system: ${system}");

          adguard-cli = pkgs.stdenv.mkDerivation {
            pname = "adguard-cli";
            inherit version;

            src = pkgs.fetchurl {
              url = "${adguardCliAsset.baseUrl}/${asset.name}";
              inherit (asset) sha256;
            };

            dontBuild = true;
            sourceRoot = asset.sourceRoot;

            unpackPhase = ''
              tar -xzf $src
            '';

            installPhase = ''
              mkdir -p $out/bin
              ls -la .
              cp ./* $out/bin/
              chmod 0755 $out/bin/adguard-cli
            '';

            meta = with pkgs.lib; {
              description = "AdGuard for Linux CLI";
              homepage = "https://github.com/AdguardTeam/AdGuardCLI";
              license = licenses.unfree;
              platforms = [
                "x86_64-linux"
                "aarch64-linux"
              ];
              maintainers = [ "chadnorvell" ];
            };
          };
        in
        {
          packages.adguard-cli = adguard-cli;
          packages.default = adguard-cli;
        }
      );
}
