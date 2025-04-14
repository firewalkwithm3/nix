{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.postgres;
in
{
  options.${namespace}.services.postgres = with types; {
    enable = mkBoolOpt false "Enable postgres - database";
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_16;
      ensureDatabases = [
        "authentik"
        "forgejo"
        "immich"
        "invidious"
        "matrix-synapse"
        "mautrix-meta-instagram"
        "mautrix-meta-facebook"
        "miniflux"
        "memos"
        "nextcloud"
        "paperless"
        "vaultwarden"
      ];
      ensureUsers = [
        {
          name = "authentik";
          ensureDBOwnership = true;
        }
        {
          name = "forgejo";
          ensureDBOwnership = true;
        }
        {
          name = "immich";
          ensureDBOwnership = true;
        }
        {
          name = "invidious";
          ensureDBOwnership = true;
        }
        {
          name = "matrix-synapse";
          ensureDBOwnership = true;
        }
        {
          name = "mautrix-meta-instagram";
          ensureDBOwnership = true;
        }
        {
          name = "mautrix-meta-facebook";
          ensureDBOwnership = true;
        }
        {
          name = "memos";
          ensureDBOwnership = true;
        }
        {
          name = "miniflux";
          ensureDBOwnership = true;
        }
        {
          name = "nextcloud";
          ensureDBOwnership = true;
        }
        {
          name = "paperless";
          ensureDBOwnership = true;
        }
        {
          name = "vaultwarden";
          ensureDBOwnership = true;
        }
      ];
      identMap = ''
        # ArbitraryMapName systemUser DBUser
        superuser_map      postgres  postgres
        superuser_map      fern      postgres
        # Let other names login as themselves
        superuser_map      /^(.*)$   \1
      '';
      authentication = pkgs.lib.mkOverride 10 ''
        #type database  DBuser  auth-method
        local all       all     trust
      '';
    };
  };
}
