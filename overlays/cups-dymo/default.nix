{
  ...
}:
final: prev: {
  cups-dymo =
    let
      repo = final.fetchFromGitHub {
        owner = "dymosoftware";
        repo = "Drivers";
        rev = "3afffc18a2c1fad110b83c6c901c3ed9fc157ad2";
        hash = "sha256-fjBykzca3od/QlhdOPZCeFBvyQMxrDjN2wRbdSklG0s=";
      };
    in
    prev.cups-dymo.overrideAttrs (old: {
      dl-name = null;

      src = "${repo}/LW5xx_Linux";

      patches = [ ./include-ctime.patch ];

      nativeBuildInputs = [ final.autoreconfHook ];
      buildInputs = old.buildInputs ++ [ final.boost ];
    });
}
