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
    dataDir = mkStrOpt "/var/lib/webone" "Data directory";
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.openFirewall {
      networking.firewall.interfaces.end0.allowedTCPPorts = [ cfg.port ];
    })

    {
      users.users.${cfg.user} = {
        group = cfg.group;
        home = cfg.dataDir;
        isSystemUser = true;
      };

      users.groups.${cfg.group} = { };

      systemd.tmpfiles.settings."10-webone" = {
        "${cfg.logDir}".d = {
          inherit (cfg) user group;
          mode = "0775";
        };

        "${cfg.dataDir}".d = {
          inherit (cfg) user group;
          mode = "0770";
        };
      };

      environment.etc = {
        "webone.conf.d/ssl.conf".text = generators.toINI { } {
          SecureProxy = {
            SslCertificate = "${cfg.dataDir}/ssl.crt";
            SslPrivateKey = "${cfg.dataDir}/ssl.key";
          };
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
          Environment = [ "OPENSSL_CONF=${pkgs.${namespace}.webone}/lib/webone/openssl_webone.cnf" ];
          TimeoutStopSec = 10;
          Restart = "on-failure";
          RestartSec = 5;
          StartLimitBurst = 3;
        };
      };
    }
  ]);
}
