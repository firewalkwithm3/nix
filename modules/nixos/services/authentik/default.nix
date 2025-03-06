{
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
      rekeyFile = ../../../../secrets/services/authentik.age;
      owner = "authentik";
      group = "authentik";
    };
    age.secrets.authentik-ldap = {
      rekeyFile = ../../../../secrets/services/authentik-ldap.age;
      owner = "authentik";
      group = "authentik";
    };

    services.authentik = {
      enable = true;
      environmentFile = config.age.secrets.authentik.path;
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
