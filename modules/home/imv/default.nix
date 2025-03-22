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
  cfg = config.${namespace}.apps.imv;
in
{
  options.${namespace}.apps.imv = with types; {
    enable = mkBoolOpt config.${namespace}.window-manager.niri.enable "Enable imv - image viewer";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      imv
    ];
  };
}
