{
  config,
  lib,
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
    enable = mkBoolOpt false "Enable udiskie - removable drive manager";
  };

  config = mkIf cfg.enable {
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
