{
  inputs,
  config,
  lib,
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

    age.secrets.minecraft.rekeyFile = (inputs.self + "/secrets/services/minecraft.age");

    virtualisation.oci-containers.containers = {
      minecraft = {
        image = "itzg/minecraft-server";
        ports = [ "${toString cfg.port}:${toString cfg.port}" ];
        volumes = [
          "minecraft:/data"
        ];
        environmentFiles = [ config.age.secrets.minecraft.path ];
        environment = {
          EULA = "TRUE";
          TZ = "Australia/Perth";
          TYPE = "PAPER";
          VERSION = "LATEST";
          MEMORY = "10G";
          MOTD = "meow";
          DIFFICULTY = "hard";
          ICON = "https://raw.githubusercontent.com/firewalkwithm3/nix/refs/heads/main/packages/www-transgender-pet/images/server-icon.png";
          OVERRIDE_ICON = "TRUE";
          MAX_PLAYERS = "10";
          SNOOPER_ENABLED = "false";
          SPAWN_PROTECTION = "0";
          PVP = "false";
          VIEW_DISTANCE = "24";
          SIMULATION_DISTANCE = "12";
          ENABLE_WHITELIST = "true";
          OVERRIDE_WHITELIST = "true";
          USE_AIKAR_FLAGS = "true";
          MODRINTH_PROJECTS = ''
            essentialsx
            essentialsx-antibuild
            essentialsx-chat-module
            essentialsx-protect
            essentialsx-spawn
            luckperms
          '';
          PLUGINS = ''
            https://dev.bukkit.org/projects/dead-chest/files/latest
          '';
          SPIGET_RESOURCES = "40313"; # ChestCleaner
        };
        extraOptions = [
          "--pull=newer"
          "--tty"
        ];
      };
    };

  };
}
