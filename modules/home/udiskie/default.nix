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
  cfg = config.${namespace}.window-manager.udiskie;
in
{
  options.${namespace}.window-manager.udiskie = with types; {
    enable =
      mkBoolOpt config.${namespace}.window-manager.niri.enable
        "Enable udiskie - removable drive manager";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ udiskie ];

    systemd.user.services.udiskie.Unit.After = mkForce [
      "tray.target"
      "graphical-session.target"
    ];

    services.udiskie = {
      enable = true;
      automount = true;
      notify = true;
      tray = "always";
    };
  };
}
