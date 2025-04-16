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
  cfg = config.${namespace}.services.nextcloud;
  dataDir = "${(containerDataDir "nextcloud")}${config.containers.nextcloud.config.services.nextcloud.home}";
in
{
  options.${namespace}.services.nextcloud = with types; {
    enable = mkBoolOpt false "Enable nextcloud - cloud storage service";
    port = mkOpt port 80 "Port to run on";
    host = mkStrOpt "192.168.100.24" "IP to bind to";
  };

  config = mkIf cfg.enable {
    age.secrets = {
      nextcloud = {
        rekeyFile = (inputs.self + "/secrets/services/nextcloud.age");
        owner = "999";
        group = "999";
      };
    };

    containers.nextcloud = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.20";
      localAddress = cfg.host;
      bindMounts = {
        "${config.age.secrets.nextcloud.path}".isReadOnly = true;
        "/var/run/postgresql".mountPoint = "/run/postgresql";
      };

      config =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        {
          services.nextcloud = {
            enable = true;
            package = pkgs.nextcloud30;
            configureRedis = true;
            enableImagemagick = true;
            https = true;
            hostName = "localhost";
            phpOptions = {
              "opcache.interned_strings_buffer" = "10";
            };
            config = {
              dbhost = "/run/postgresql";
              adminuser = "fern";
              adminpassFile = "/run/agenix/nextcloud";
              dbtype = "pgsql";
            };
            settings = {
              overwriteprotocol = "https";
              overwritehost = "cloud.ferngarden.net";
              trusted_domains = [ "cloud.ferngarden.net" ];
              trusted_proxies = [ "127.0.0.1" ];
              default_phone_region = "AU";
              log_type = "file";
              maintenance_window_start = 8;
            };
            autoUpdateApps.enable = true;
            appstoreEnable = false;
            extraApps = {
              inherit (config.services.nextcloud.package.packages.apps)
                bookmarks
                calendar
                contacts
                user_oidc
                gpoddersync
                ;
              dav_push = pkgs.fetchNextcloudApp rec {
                appName = "dav_push";
                appVersion = "0.0.2";
                url = "https://github.com/bitfireAT/nc_ext_dav_push/releases/download/v${appVersion}/dav_push.tar.gz";
                sha256 = "sha256-XRDZHZFHQ1GChWE7Ps5lqhf7aPO4qZtWGoz8wBFQl/g=";
                license = "agpl3Only";
              };
            };
            extraAppsEnable = true;
          };

          system.stateVersion = "24.11";
          networking = {
            firewall = {
              enable = true;
              allowedTCPPorts = [ cfg.port ];
            };
            useHostResolvConf = lib.mkForce false;
          };

          services.resolved.enable = true;
        };
    };

    ${namespace} = {
      backups.modules.nextcloud = {
        directories = [ dataDir ];
      };

      services.postgres.databases = [ "nextcloud" ];

      services.caddy.services.nextcloud = {
        port = cfg.port;
        host = cfg.host;
        subdomain = "cloud";
        domain = "ferngarden.net";
      };
    };
  };
}
