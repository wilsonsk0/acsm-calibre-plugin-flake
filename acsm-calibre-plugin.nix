{
pkgs,
src 
}:
pkgs.stdenvNoCC.mkDerivation {
  pname = "acsm-calibre-plugin";
  version = "git";
  inherit src;

  nativeBuildInputs = with pkgs; [ 
    bash
    zip
  ];

  buildInputs = with pkgs; [
    openssl
  ];

  buildPhase = ''
    runHook preBuild
    
    patchShebangs .
    ./bundle_calibre_plugin.sh

    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp calibre-plugin.zip $out/acsm-calibre-plugin.zip

    runHook postInstall
  '';
}

