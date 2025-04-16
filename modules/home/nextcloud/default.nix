{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.apps.nextcloud;
in
{
  options.${namespace}.apps.nextcloud = with types; {
    enable =
      mkBoolOpt config.${namespace}.window-manager.niri.enable
        "Enable nextcloud client - cloud storage";
  };

  config = mkIf cfg.enable {
    systemd.user.services.nextcloud-client.Unit.After = mkForce [
      "tray.target"
      "graphical-session.target"
    ];

    services.nextcloud-client = {
      enable = true;
      startInBackground = true;
    };

    ${namespace}.impermanence.directories = [
      "Nextcloud"
      ".config/Nextcloud"
    ];
  };
}
