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
  cfg = config.${namespace}.services.authentik;
in
{
  options.${namespace}.services.authentik = with types; {
    enable = mkBoolOpt config.${namespace}.services.caddy.enable "Enable Authentik";
    port = mkOpt port 9000 "Port to run on";
  };

  config = mkIf cfg.enable {
    age.secrets.authentik = {
      rekeyFile = (inputs.self + "/secrets/services/authentik.age");
      owner = "authentik";
      group = "authentik";
    };
    age.secrets.authentik-ldap = {
      rekeyFile = (inputs.self + "/secrets/services/authentik-ldap.age");
      owner = "authentik";
      group = "authentik";
    };

    services.authentik = {
      enable = true;
      environmentFile = config.age.secrets.authentik.path;
      settings.email = {
        host = "mail.ferngarden.net";
        port = 465;
        username = "admin@ferngarden.net";
        use_tls = false;
        use_ssl = true;
        from = "admin@ferngarden.net";
      };
    };

    services.authentik-ldap = {
      enable = true;
      environmentFile = config.age.secrets.authentik-ldap.path;
    };

    ${namespace}.services.caddy.services.authentik = {
      port = cfg.port;
      subdomain = "auth";
      domain = "fern.garden";
    };
  };
}
