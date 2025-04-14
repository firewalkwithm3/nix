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
  cfg = config.${namespace}.services.matrix-synapse;
in
{
  options.${namespace}.services.matrix-synapse = with types; {
    enable = mkBoolOpt false "Enable matrix-synapse - encrypted chat server";
    port = mkOpt port 8008 "Port to run on";
    federation.port = mkOpt port 8448 "Port for federation";
  };

  config = mkIf cfg.enable {
    age.secrets = {
      matrix = {
        rekeyFile = (inputs.self + "/secrets/services/matrix.age");
        owner = "matrix-synapse";
        group = "matrix-synapse";
      };
      matrix-doublepuppet = {
        rekeyFile = (inputs.self + "/secrets/services/matrix-doublepuppet.age");
        owner = "matrix-synapse";
        group = "matrix-synapse";
      };
      mautrix.rekeyFile = (inputs.self + "/secrets/services/mautrix.age");
    };

    networking.firewall.allowedTCPPorts = [ cfg.federation.port ];

    services.matrix-synapse = {
      enable = true;
      configureRedisLocally = true;
      extras = [
        "oidc"
        "systemd"
        "postgres"
        "redis"
        "url-preview"
        "user-search"
      ];
      extraConfigFiles = [ config.age.secrets.matrix.path ];
      settings = {
        server_name = "mx.fern.garden";
        app_service_config_files = [ config.age.secrets.matrix-doublepuppet.path ];
        listeners = [
          {
            bind_addresses = [ "127.0.0.1" ];
            port = cfg.port;
            x_forwarded = true;
            type = "http";
            tls = false;
            resources = [
              {
                names = [
                  "client"
                  "federation"
                ];
                compress = false;
              }
            ];
          }
        ];
        report_stats = false;
        trusted_key_servers = [
          {
            server_name = "matrix.org";
          }
        ];
      };
    };

    services.mautrix-discord = {
      enable = true;
      environmentFile = config.age.secrets.mautrix.path;
      settings = {
        homeserver = {
          address = "http://127.0.0.1:8008";
          domain = "mx.fern.garden";
          database = {
            type = "postgres";
            uri = "postgresql:///mautrix-discord?host=/var/run/postgresql";
          };
        };
        bridge = {
          permissions."@fern:mx.fern.garden" = "admin";
          login_shared_secret_map."mx.fern.garden" = "as_token:$AS_TOKEN";
        };
      };
    };

    services.mautrix-meta.instances = {
      instagram = {
        enable = true;
        environmentFile = config.age.secrets.mautrix.path;
        settings = {
          homeserver = {
            address = "http://127.0.0.1:8008";
            domain = "mx.fern.garden";
          };
          database = {
            type = "postgres";
            uri = "postgresql:///mautrix-meta-instagram?host=/var/run/postgresql";
          };
          bridge.permissions."@fern:mx.fern.garden" = "admin";
          double_puppet.secrets."mx.fern.garden" = "as_token:$AS_TOKEN";
        };
      };

      facebook = {
        enable = true;
        environmentFile = config.age.secrets.mautrix.path;
        settings = {
          homeserver = {
            address = "http://127.0.0.1:8008";
            domain = "mx.fern.garden";
          };
          database = {
            type = "postgres";
            uri = "postgresql:///mautrix-meta-facebook?host=/var/run/postgresql";
          };
          bridge.permissions."@fern:mx.fern.garden" = "admin";
          double_puppet.secrets."mx.fern.garden" = "as_token:$AS_TOKEN";
        };
      };
    };

    ${namespace} = {
      backups.modules.matrix-synapse = {
        directories = [
          config.services.matrix-synapse.settings.signing_key_path
          config.services.matrix-synapse.settings.media_store_path
        ];
      };
      services.caddy.services.matrix-synapse = {
        port = cfg.port;
        subdomain = "mx";
        domain = "fern.garden";
      };
    };
  };
}
