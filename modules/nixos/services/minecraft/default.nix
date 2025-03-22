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
  cfg = config.${namespace}.services.minecraft;
in
{
  options.${namespace}.services.minecraft = with types; {
    enable = mkBoolOpt false "Enable paper minecraft server";
    port = mkOpt port 25565 "Port to run on";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    services.minecraft-server = {
      enable = true;
      eula = true;
      package = pkgs.papermc;
      jvmOpts = "-Xms4092M -Xmx4092M";
    };

  };
}
