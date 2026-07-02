{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    acsm-calibre-plugin = {
      url = "github:Leseratte10/acsm-calibre-plugin/336431fdce44be13514c5cc4e66e25da7ef3dc26";
      flake = false;
    };
    dedrm-calibre-plugin = {
      url = "github:noDRM/DeDRM_tools/7379b453199ed1ba91bf3a4ce4875d5ed3c309a9";
      flake = false;
    };
  };

  outputs = inputs@{ flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } ({ ... }: 
  {
    systems = [ "x86_64-linux" ];
    perSystem = { pkgs, self', ... }: {
      packages = {
        acsm-calibre-plugin = pkgs.callPackage ./acsm-calibre-plugin.nix { src = inputs.acsm-calibre-plugin; };
        dedrm-calibre-plugin = pkgs.callPackage ./dedrm-calibre-plugin.nix { src = inputs.dedrm-calibre-plugin; };
        calibre = pkgs.symlinkJoin {
          name = "calibre-wrapped";
          paths = [ pkgs.calibre ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/calibre \
              --prefix PYTHONPATH : ${pkgs.python3.pkgs.makePythonPath [
                pkgs.python3.pkgs.oscrypto
              ]} \
              --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [ pkgs.openssl ]}
          '';
        };
        default = self'.packages.calibre;
      };
    };
    flake = { self, ... }: {
      homeModules.calibre = { pkgs, ... }: {
        home.packages = [
          self.packages.${pkgs.system}.calibre
        ];

        xdg.configFile."calibre/plugins/DeACSM.zip".source =
          "${self.packages.${pkgs.system}.acsm-calibre-plugin}/acsm-calibre-plugin.zip";

        xdg.configFile."calibre/plugins/DeDRM.zip".source =
          "${self.packages.${pkgs.system}.dedrm-calibre-plugin}/dedrm-calibre-plugin.zip";
      };
    };
  });
}
