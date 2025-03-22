{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.apps.hunspell;
in
{
  options.${namespace}.apps.hunspell = with types; {
    enable = mkBoolOpt config.${namespace}.window-manager.niri.enable "Enable spell checker";
  };

  config =
    mkIf
      (
        cfg.enable
        && (config.${namespace}.apps.firefox.enable || config.${namespace}.apps.libreoffice.enable)
      )
      {
        home.packages = with pkgs; [
          hunspell
          hunspellDicts.en_AU
        ];
      };
}
