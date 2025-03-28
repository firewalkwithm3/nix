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
  cfg = config.${namespace}.apps.libreoffice;
in
{
  options.${namespace}.apps.libreoffice = with types; {
    enable = mkBoolOpt config.${namespace}.window-manager.niri.enable "Enable libreoffice - office suite";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      libreoffice-still
    ];
  };
}
