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
  cfg = config.${namespace}.apps.cinny;
in
{
  options.${namespace}.apps.cinny = with types; {
    enable = mkBoolOpt config.${namespace}.window-manager.niri.enable "Enable cinny - matrix client";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      cinny
    ];
  };
}
