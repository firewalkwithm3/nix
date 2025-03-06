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
  cfg = config.${namespace}.services.caddy;

  service = {
    options = with types; {
      port = mkOption {
        type = port;
        description = "The service's port";
      };

      subdomain = mkOption {
        type = str;
        description = "The subdomain the service is running on";
      };

      domain = mkOption {
        type = str;
        description = "The domain the service is running on";
      };

      host = mkOption {
        type = str;
        default = "127.0.0.1";
        description = "The IP the service is listening on";
      };
    };
  };

  mkProxies =
    with lib.attrsets;
    proxyServices:
    mapAttrs' (
      name: service:
      nameValuePair "${service.subdomain}.${service.domain}" {
        extraConfig = "reverse_proxy ${service.host}:${toString service.port}";
        logFormat = mkMerge [
          (mkIf (service.domain == "fern.garden") ''
            output file ${config.services.caddy.logDir}/fern.garden.log { mode 0644 }
          '')
          (mkIf (service.domain == "transgender.pet") ''
            output file ${config.services.caddy.logDir}/transgender.pet.log { mode 0644 }
          '')
          (mkIf (service.domain == "ferngarden.net") ''
            output file ${config.services.caddy.logDir}/ferngarden.net.log { mode 0644 }
          '')
        ];
      }
    ) proxyServices;
in
{
  options.${namespace}.services.caddy = with types; {
    enable = mkBoolOpt false "Enable Caddy webserver & reverse proxy";
    services = mkOpt (attrsOf (submodule service)) { } "The services to proxy";
    domains = mkOpt (listOf str) [
      "ferngarden.net"
      "fern.garden"
      "transgender.pet"
    ] "Active domains";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 443 ];

    age.secrets = {
      caddy = {
        rekeyFile = ../../../../secrets/services/caddy.age;
        owner = "caddy";
        group = "caddy";
      };
    };

    systemd.services.caddy.serviceConfig.EnvironmentFile = [ config.age.secrets.caddy.path ];

    systemd.services.caddy.serviceConfig = {
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
    };

    services.caddy = {
      enable = true;

      package = pkgs.caddy.withPlugins {
        plugins = [
          "github.com/caddy-dns/porkbun@v0.2.1"
          "github.com/hslatman/caddy-crowdsec-bouncer@v0.7.2"
        ];
        hash = "sha256-HeHOXg90lA2JcAsc9DVt5/uSlz1xfO5810lQEQDqnqg=";
      };

      globalConfig = ''
        email ${config.${namespace}.user.email}

        crowdsec {
          api_url http://127.0.0.1:${toString (config.${namespace}.services.crowdsec.port)}
          api_key {$CROWDSEC_BOUNCER_API_KEY}
        }

        auto_https prefer_wildcard
      '';

      virtualHosts =
        let
          hostCfg = host: {
            logFormat = mkMerge [
              (mkIf ((strings.removePrefix "*." host) == "fern.garden") ''
                output file ${config.services.caddy.logDir}/fern.garden.log { mode 0644 }
              '')
              (mkIf ((strings.removePrefix "*." host) == "transgender.pet") ''
                output file ${config.services.caddy.logDir}/transgender.pet.log { mode 0644 }
              '')
              (mkIf ((strings.removePrefix "*." host) == "ferngarden.net") ''
                output file ${config.services.caddy.logDir}/ferngarden.net.log { mode 0644 }
              '')
            ];
            extraConfig = mkMerge [
              ''
                handle_errors {
                  respond "{err.status_code} {err.status_text}"
                }
              ''

              (mkIf (strings.hasPrefix "*." host) ''
                handle { redir https://${(strings.removePrefix "*." host)} }
              '')

              (mkIf (!strings.hasPrefix "*." host) ''
                root * /var/www/${host}
                file_server
              '')

              (mkIf ((strings.removePrefix "*." host) != "ferngarden.net") ''
                route { crowdsec }
              '')
            ];
          };
        in
        flip genAttrs hostCfg (lists.concatMap (domain: [ domain ] ++ [ "*.${domain}" ]) cfg.domains)
        // mkProxies cfg.services;
    };
  };
}
