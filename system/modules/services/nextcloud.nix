{
  config,
  lib,
  ...
}:

{
  age.secrets = {
    nextcloud = {
      rekeyFile = ../../../secrets/services/nextcloud.age;
      owner = "999";
      group = "999";
    };
  };

  containers.nextcloud = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.20";
    localAddress = "192.168.100.24";
    bindMounts = {
      "${config.age.secrets.nextcloud.path}".isReadOnly = true;
      "/var/run/postgresql".mountPoint = "/var/run/postgresql";
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
            dbhost = "/var/run/postgresql";
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
              ;
          };
          extraAppsEnable = true;
        };

        system.stateVersion = "23.11";
        networking = {
          firewall = {
            enable = true;
            allowedTCPPorts = [ 80 ];
          };
          useHostResolvConf = lib.mkForce false;
        };

        services.resolved.enable = true;
      };
  };

  services.caddy.virtualHosts."cloud.ferngarden.net" = {
    logFormat = lib.mkForce ''
      	    output discard
      	  '';
    extraConfig = ''
      	    reverse_proxy 192.168.100.24:80
      	  '';
  };
}
