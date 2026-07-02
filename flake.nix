{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    src = {
      url = "github:Leseratte10/acsm-calibre-plugin/336431fdce44be13514c5cc4e66e25da7ef3dc26";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, src }: 
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in
  {
    packages."${system}" = {
      ascm-calibre-plugin = pkgs.stdenvNoCC.mkDerivation {
        pname = "acsm-calibre-plugin";
        version = "git";
        inherit src;

        nativeBuildInputs = with pkgs; [ 
          bash
          zip
        ];

        buildInputs = with pkgs; [
          openssl
          python3
        ];

        buildPhase = ''
          runHook preBuild
          
          patchShebangs .
          ./bundle_calibre_plugin.sh

          runHook preBuild
        '';
        installPhase = ''
          runHook preInstall

          mkdir -p $out
          cp calibre-plugin.zip $out/acsm-calibre-plugin.zip

          runHook postInstall
        '';
      };
      default = self.packages."${system}".ascm-calibre-plugin;
    };
  };
}
