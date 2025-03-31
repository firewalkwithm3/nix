{
  appimageTools,
  fetchurl,
  makeWrapper,
}:
let
  pname = "beeper";
  version = "4.0.570";

  src = fetchurl {
    url = "https://beeper-desktop.download.beeper.com/builds/Beeper-${version}.AppImage";
    hash = "sha256-rzFT7NfXeFt9W3DjJ0yyCzTtPSdB+FjYQHjxPbeMciU=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: [ pkgs.libsecret ];

  nativeBuildInputs = [ makeWrapper ];

  extraInstallCommands = ''
    mkdir -p $out/share/${pname}
    cp -a ${appimageContents}/locales $out/share/${pname}
    cp -a ${appimageContents}/resources $out/share/${pname}

    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/512x512/apps/beepertexts.png \
      $out/share/icons/hicolor/512x512/apps/${pname}.png

    install -Dm 444 ${appimageContents}/beepertexts.desktop \
      $out/share/applications/${pname}.desktop
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${pname}'
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Icon=beepertexts' 'Icon=${pname}'

    wrapProgram $out/bin/${pname} \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}} --no-update"
  '';
}
