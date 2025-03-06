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
    enable = mkBoolOpt false "Enable Nextcloud client";
  };

  config = mkIf cfg.enable {
    systemd.user.services.nextcloud-client.Unit.After = mkForce [ "tray.target" ];

    services.nextcloud-client = {
      enable = true;
      startInBackground = true;
    };
  };
}
