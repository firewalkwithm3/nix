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
  cfg = config.${namespace}.services.crowdsec;
in
{
  options.${namespace}.services.crowdsec = with types; {
    enable = mkBoolOpt config.${namespace}.services.caddy.enable "Enable crowdsec";
    port = mkOpt port 8091 "Port to run on";
  };

  config = mkIf cfg.enable {
    age.secrets = {
      crowdsec = {
        rekeyFile = (inputs.self + "/secrets/services/crowdsec.age");
        owner = "crowdsec";
        group = "crowdsec";
      };
      crowdsec-bouncer = {
        rekeyFile = (inputs.self + "/secrets/services/crowdsec-bouncer.age");
        owner = "crowdsec";
        group = "crowdsec";
      };
    };

    systemd.services.crowdsec-firewall-bouncer.serviceConfig.EnvironmentFile = [
      config.age.secrets.crowdsec-bouncer.path
    ];

    systemd.services.crowdsec.serviceConfig.EnvironmentFile = [
      config.age.secrets.crowdsec-bouncer.path
    ];

    systemd.services.crowdsec.serviceConfig = {
      ExecStartPre =
        let
          script = pkgs.writeScriptBin "register-bouncer" ''
            #!${pkgs.runtimeShell}
            set -eu
            set -o pipefail

            if ! cscli bouncers list | grep -q "caddy"; then
              cscli bouncers add "caddy" --key "''${API_KEY}"
            fi
          '';
        in
        [ "${script}/bin/register-bouncer" ];
    };

    services.crowdsec = {
      enable = true;
      enrollKeyFile = config.age.secrets.crowdsec.path;
      acquisitions = [
        {
          filenames = [
            "/var/log/caddy/fern.garden.log"
            "/var/log/caddy/transgender.pet.log"
          ];
          labels.type = "caddy";
        }
      ];
      settings = {
        api.server = {
          listen_uri = "127.0.0.1:${toString cfg.port}";
        };
      };
    };

    services.crowdsec-firewall-bouncer = {
      enable = true;
      settings = {
        api_key = ''''${API_KEY}'';
        api_url = "http://127.0.0.1:${toString cfg.port}";
      };
    };

  };
}
