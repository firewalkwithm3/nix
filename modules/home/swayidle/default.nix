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
  cfg = config.${namespace}.window-manager.swayidle;
in
{
  options.${namespace}.window-manager.swayidle = with types; {
    enable =
      mkBoolOpt config.${namespace}.window-manager.niri.enable
        "Enable swayidle - idle management daemon";
  };

  config = mkIf (cfg.enable && config.${namespace}.window-manager.gtklock.enable) {
    systemd.user.services.swayidle.Unit.After = mkForce [ "graphical-session.target" ];

    services.swayidle = {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = "${pkgs.gtklock}/bin/gtklock -d";
        }
      ];
      timeouts = [
        {
          timeout = 300;
          command = "${pkgs.gtklock}/bin/gtklock -d";
        }
      ];
    };
  };
}
