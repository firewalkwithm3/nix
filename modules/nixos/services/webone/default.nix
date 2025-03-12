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
  cfg = config.${namespace}.services.webone;
in
{
  options.${namespace}.services.webone = with types; {
    enable = mkBoolOpt false "Enable webone";
    port = mkOpt port 8080 "Port to run on";
    openFirewall = mkBoolOpt true "Open port in firewall";
    user = mkStrOpt "webone" "User to run webone as";
    group = mkStrOpt "webone" "Group to run webone as";
    logDir = mkStrOpt "/var/log/webone" "Log directory";
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.openFirewall {
      networking.firewall.interfaces.end0.allowedTCPPorts = [ cfg.port ];
    })

    {
      users.users.${cfg.user} = {
        group = cfg.group;
        home = "/var/lib/webone";
        isSystemUser = true;
      };

      users.groups.${cfg.group} = { };

      systemd.tmpfiles.settings."10-webone" = {
        "${cfg.logDir}".d = {
          inherit (cfg) user group;
          mode = "0775";
        };
      };

      systemd.services.webone = {
        description = "WebOne HTTP Proxy Server";
        after = [ "network-online.target" ];
        requires = [ "network-online.target" ];
        documentation = [ "https://github.com/atauenis/webone/wiki/" ];

        unitConfig = {
          StartLimitInterval = "5s";
        };

        serviceConfig = {
          Type = "simple";
          User = cfg.user;
          Group = cfg.group;
          ExecStart = "${pkgs.${namespace}.webone}/bin/webone --daemon --log ${cfg.logDir}/webone.log";
          TimeoutStopSec = 10;
          Restart = "on-failure";
          RestartSec = 5;
          StartLimitBurst = 3;
        };
      };
    }
  ]);
}
