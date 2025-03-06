{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.window-manager.wlsunset;
in
{
  options.${namespace}.window-manager.wlsunset = with types; {
    enable = mkBoolOpt false "Enable wlsunset service";
  };

  config = mkIf cfg.enable {
    systemd.user.services.wlsunset.Unit.After = mkForce [ "graphical-session.target" ];

    services.wlsunset = {
      enable = true;
      systemdTarget = "graphical-session.target";
      latitude = -27.6;
      longitude = 121.6;
    };
  };
}
