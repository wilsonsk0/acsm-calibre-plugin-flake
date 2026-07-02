{
pkgs,
src
}:
pkgs.stdenvNoCC.mkDerivation {
  pname = "dedrm-calibre-plugin";
  version = "git";
  inherit src;

  nativeBuildInputs = with pkgs; [
    zip
    python3
  ];

  buildPhase = ''
    runHook preBuild

    patchShebangs .

    # ZIP format cannot encode timestamps before 1980.
    find . -exec touch -d @315532800 {} +

    python3 make_release.py

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp DeDRM_tools.zip $out/dedrm-calibre-plugin.zip

    runHook postInstall
  '';
}
