{
  config,
  lib,
  pkgs,
  ...
}:

{
  age.secrets = {
    nextcloud = {
      rekeyFile = ../../../secrets/services/nextcloud.age;
      owner = "nextcloud";
      group = "nextcloud";
    };
  };

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
      adminpassFile = config.age.secrets.nextcloud.path;
      dbtype = "pgsql";
    };
    settings = {
      overwriteprotocol = "https";
      overwritehost = "cloud.ferngarden.net";
      trusted_domains = [ "cloud.ferngarden.net" ];
      trusted_proxies = [ "127.0.0.1" ];
      defaultPhoneRegion = "AU";
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

  # run on a different port
  services.nginx.virtualHosts."localhost".listen = [
    {
      addr = "127.0.0.1";
      port = 8082;
    }
  ];

  services.caddy.virtualHosts."cloud.ferngarden.net" = {
    logFormat = lib.mkForce ''
      	    output discard
      	  '';
    extraConfig = ''
      	    reverse_proxy 127.0.0.1:8082
      	  '';
  };
}
