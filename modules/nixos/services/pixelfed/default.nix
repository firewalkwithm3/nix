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
  cfg = config.${namespace}.services.pixelfed;
in
{
  options.${namespace}.services.pixelfed = with types; {
    enable = mkBoolOpt false "Enable pixelfed - social photo sharing platform";
    port = mkOpt port 80 "Port to run on";
    host = mkStrOpt "192.168.100.23" "IP to bind to";
  };

  config = mkIf cfg.enable {
    age.secrets.pixelfed = {
      rekeyFile = (inputs.self + "/secrets/services/pixelfed.age");
      owner = "972";
      group = "971";
    };

    containers.pixelfed = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.20";
      localAddress = cfg.host;
      bindMounts = {
        "${config.age.secrets.pixelfed.path}".isReadOnly = true;
      };

      config =
        {
          lib,
          pkgs,
          ...
        }:
        let
          pf-localfs-patch = pkgs.writeText "01-local-filesystem.patch" ''
            diff --git a/config/filesystems.php b/config/filesystems.php
            index 00254e93..fc1a58f3 100644
            --- a/config/filesystems.php
            +++ b/config/filesystems.php
            @@ -49,11 +49,11 @@ return [
                         'permissions' => [
                             'file' => [
                                 'public' => 0644,
            -                    'private' => 0600,
            +                    'private' => 0640,
                             ],
                             'dir' => [
                                 'public' => 0755,
            -                    'private' => 0700,
            +                    'private' => 0750,
                             ],
                         ],
                     ],
          '';
        in
        {
          services.pixelfed = {
            enable = true;
            package = pkgs.pixelfed.overrideAttrs (old: {
              patches = (old.patches or [ ]) ++ [ "${pf-localfs-patch}" ];
            });
            domain = "pixelfed.fern.garden";
            maxUploadSize = "20M";
            secretFile = "/run/agenix/pixelfed";
            nginx = { };
            settings = {
              APP_URL = "https://pixelfed.fern.garden";
              OAUTH_ENABLE = true;
              STORIES_ENABLED = true;
              INSTANCE_PROFILE_EMBEDS = false;
              INSTANCE_POST_EMBEDS = false;
              INSTANCE_LANDING_SHOW_DIRECTORY = false;
              INSTANCE_LANDING_SHOW_EXPLORE = false;
              OPEN_REGISTRATION = false;
              MAX_BIO_LENGTH = 500;
              MAIL_DRIVER = "smtp";
              MAIL_HOST = "mail.ferngarden.net";
              MAIL_PORT = 465;
              MAIL_USERNAME = "admin@ferngarden.net";
              MAIL_ENCRYPTION = "ssl";
              MAIL_FROM_ADDRESS = "admin@ferngarden.net";
              MAIL_FROM_NAME = "admin@ferngarden.net";
            };
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

    ${namespace}.services.caddy.services.pixelfed = {
      port = cfg.port;
      host = cfg.host;
      subdomain = "pixelfed";
      domain = "fern.garden";
    };
  };
}
