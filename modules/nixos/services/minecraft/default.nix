{
  inputs,
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

  globalConfig = {
    EULA = "TRUE";
    TZ = "Australia/Perth";
    TYPE = "PAPER";
    OVERRIDE_ICON = "TRUE";
    ONLINE_MODE = "FALSE";
    MEMORY = "8G";
    DIFFICULTY = "normal";
    MAX_PLAYERS = "10";
    SNOOPER_ENABLED = "false";
    SPAWN_PROTECTION = "0";
    PVP = "false";
    VIEW_DISTANCE = "24";
    SIMULATION_DISTANCE = "12";
    ENABLE_WHITELIST = "true";
    OVERRIDE_WHITELIST = "true";
    USE_AIKAR_FLAGS = "true";
    ENABLE_RCON = "false";
  };

  plugins = {
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
in
{
  options.${namespace}.services.minecraft = with types; {
    enable = mkBoolOpt false "Enable paper minecraft server";
    port = mkOpt port 25565 "Port to run on";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      cfg.port
    ];

    age.secrets.minecraft.rekeyFile = (inputs.self + "/secrets/services/minecraft.age");

    systemd.services.create-minecraft-network = {
      serviceConfig.Type = "oneshot";
      wantedBy = [ "podman-velocity.service" ];
      script = ''
        ${pkgs.podman}/bin/podman network exists minecraft || \
        ${pkgs.podman}/bin/podman network create minecraft
      '';
    };

    virtualisation.oci-containers.containers = {
      velocity = {
        image = "itzg/mc-proxy";
        ports = [ "${toString cfg.port}:${toString cfg.port}" ];
        volumes = [
          "velocity-server:/server"
          "velocity-config:/config"
        ];
        environment = {
          TYPE = "VELOCITY";
          MINECRAFT_VERSION = "1.21.5";
          MODRINTH_PROJECTS = ''
            viaversion
          '';
        };
        extraOptions = [
          "--pull=newer"
          "--network=minecraft"
        ];
      };

      minecraft-main = {
        image = "itzg/minecraft-server";
        volumes = [
          "minecraft:/data"
        ];
        dependsOn = [ "velocity" ];
        environmentFiles = [ config.age.secrets.minecraft.path ];
        environment =
          {
            SERVER_PORT = "30066";
            MOTD = "meow";
            ICON = "https://raw.githubusercontent.com/firewalkwithm3/nix/refs/heads/main/packages/www-transgender-pet/images/server-icons/transcat.png";
            VERSION = "1.21.4";
          }
          // globalConfig
          // plugins;
        extraOptions = [
          "--pull=newer"
          "--tty"
          "--network=minecraft"
        ];
      };

      minecraft-bob = {
        image = "itzg/minecraft-server";
        dependsOn = [ "velocity" ];
        volumes = [
          "minecraft-bob:/data"
          "${podmanVolumeDir}/minecraft/_data/plugins:/plugins"
        ];
        environmentFiles = [ config.age.secrets.minecraft.path ];
        environment = {
          SERVER_PORT = "30067";
          MOTD = "it's bob's world, we're just living in it";
          ICON = "https://raw.githubusercontent.com/firewalkwithm3/nix/refs/heads/main/packages/www-transgender-pet/images/server-icons/gayarmadillo.png";
          VERSION = "1.21.5";
          PAPER_CHANNEL = "experimental";
        } // globalConfig;
        extraOptions = [
          "--pull=newer"
          "--tty"
          "--network=minecraft"
        ];
      };
    };

    ${namespace} = {
      backups.modules.minecraft = {
        directories = [
          "${podmanVolumeDir}/minecraft"
          "${podmanVolumeDir}/minecraft-bob"
        ];
      };
    };
  };
}
