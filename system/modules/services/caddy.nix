{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:

{
  networking.firewall.allowedTCPPorts = [ 443 ];

  age.secrets = {
    caddy = {
      rekeyFile = ../../../secrets/services/caddy.age;
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
    package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.caddy.withPlugins {
      plugins = [
        "github.com/caddy-dns/porkbun@v0.2.1"
        "github.com/hslatman/caddy-crowdsec-bouncer@v0.7.2"
      ];
      hash = "sha256-HeHOXg90lA2JcAsc9DVt5/uSlz1xfO5810lQEQDqnqg=";
    };
    globalConfig = ''
            email admin@fern.garden

            crowdsec {
              api_url http://127.0.0.1:8091
              api_key {$CROWDSEC_BOUNCER_API_KEY}
            }

            auto_https prefer_wildcard

            acme_dns porkbun {
              api_key {$API_KEY}
      	      api_secret_key {$API_SECRET_KEY}
            }
    '';
    virtualHosts."*.ferngarden.net" = {
      logFormat = lib.mkForce ''
        output discard
      '';
      extraConfig = ''
        handle {
          redir https://ferngarden.net
        }

        handle_errors {
          respond "{err.status_code} {err.status_text}"
        }
      '';
    };
    virtualHosts."ferngarden.net" = {
      logFormat = lib.mkForce ''
        output discard
      '';
      extraConfig = ''
        respond "This page does not exist."

        handle_errors {
          respond "{err.status_code} {err.status_text}"
        }
      '';
    };
    virtualHosts."*.fern.garden" = {
      logFormat = lib.mkForce ''
        output file ${config.services.caddy.logDir}/fern_garden.log { mode 0644 }
      '';
      extraConfig = ''
        route { crowdsec }

        handle {
          redir https://fern.garden
        }

        handle_errors {
          respond "{err.status_code} {err.status_text}"
        }
      '';
    };
    virtualHosts."fern.garden" = {
      logFormat = lib.mkForce ''
        output file ${config.services.caddy.logDir}/fern_garden.log { mode 0644 }
      '';
      extraConfig = ''
        route { crowdsec }

        root * /var/www/fern.garden
        file_server

        handle_errors {
          respond "{err.status_code} {err.status_text}"
        }
      '';
    };
    virtualHosts."*.transgender.pet" = {
      logFormat = lib.mkForce ''
        output file ${config.services.caddy.logDir}/transgender_pet.log { mode 0644 }
      '';
      extraConfig = ''
        route { crowdsec }

        handle {
          redir https://transgender.pet
        }

        handle_errors {
          respond "{err.status_code} {err.status_text}"
        }
      '';
    };
    virtualHosts."transgender.pet" = {
      logFormat = lib.mkForce ''
        output file ${config.services.caddy.logDir}/transgender_pet.log { mode 0644 }
      '';
      extraConfig = ''
        route { crowdsec }

        root * /var/www/transgender.pet
        file_server

        handle_errors {
          respond "{err.status_code} {err.status_text}"
        }
      '';
    };
  };
}
