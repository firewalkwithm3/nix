{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "explo";
  version = "0.8.4";

  src = fetchFromGitHub {
    owner = "LumePart";
    repo = "Explo";
    rev = "v${version}";
    hash = "sha256-jJdNhqV3jH3N+3iCHmGAB1Z9fCfpCRLUKrYirnPwutc=";
  };
  vendorHash = "sha256-zLTJUluhZfAhEcGzapuACrzx7ycVLDyqnO7dXskt7Lw=";

  postPatch = ''
    substituteInPlace src/listenbrainz.go --replace-fail "_, creationWeek := playlist.Data.Date.ISOWeek()" "_, creationWeek := playlist.Data.Date.Local().ISOWeek()"
  '';

  postInstall = ''
    mkdir -p $out/opt/explo
    mv $out/bin/src $out/bin/explo
  '';

  meta = {
    description = "Spotify's \"Discover Weekly\" for self-hosted music systems ";
    homepage = "https://github.com/LumePart/Explo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ firewalkwithm3 ];
  };
}
