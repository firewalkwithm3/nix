{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.netatalk;
in
{
  options.${namespace}.services.netatalk = with types; {
    enable = mkBoolOpt false "Enable Netatalk (AFP implementation)";
    port = mkPortOpt 548 "Port to run Netatalk on";
  };

  config = mkIf cfg.enable {
    networking.firewall.interfaces.end0.allowedTCPPorts = [ cfg.port ];

    services.netatalk = {
      enable = true;
      port = cfg.port;
      settings = {
        Global = {
          "uam list" = "uams_guest.so";
        };
        iMacG3 = {
          path = "/srv/iMacG3";
        };
      };
    };
  };
}
