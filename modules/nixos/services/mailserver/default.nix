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
  cfg = config.${namespace}.services.mailserver;
  certDir = "${config.services.caddy.dataDir}/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory";
in
{
  options.${namespace}.services.mailserver = with types; {
    enable = mkBoolOpt false "Enable mailserver";
    domain = mkStrOpt "ferngarden.net" "Domain to run on";
  };

  config = mkIf cfg.enable {
    age.secrets.mailserver.rekeyFile = (inputs.self + "/secrets/services/mailserver.age");

    mailserver = {
      enable = true;
      fqdn = "mail.${cfg.domain}";
      domains = [ "${cfg.domain}" ];
      certificateScheme = "manual";
      certificateFile = "${certDir}/wildcard_.${cfg.domain}/wildcard_.${cfg.domain}.crt";
      keyFile = "${certDir}/wildcard_.${cfg.domain}/wildcard_.${cfg.domain}.key";
      localDnsResolver = false;

      loginAccounts = {
        "admin@ferngarden.net" = {
          hashedPasswordFile = config.age.secrets.mailserver.path;
          sendOnly = true;
          aliases = [
            "postmaster@${cfg.domain}"
            "abuse@${cfg.domain}"
          ];
        };
      };
    };
  };
}
