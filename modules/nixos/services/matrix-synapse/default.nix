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

    ${namespace}.services.caddy.services.matrix-synapse = {
      port = cfg.port;
      subdomain = "mx";
      domain = "fern.garden";
    };
  };
}
