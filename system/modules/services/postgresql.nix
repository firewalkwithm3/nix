{ pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    ensureDatabases = [
      "authentik"
      "forgejo"
      "immich"
      "invidious"
      "matrix-synapse"
      "miniflux"
      "nextcloud"
      "vaultwarden"
    ];
    ensureUsers = [
      { name = "authentik"; ensureDBOwnership = true; }
      { name = "forgejo"; ensureDBOwnership = true; }
      { name = "immich"; ensureDBOwnership = true; }
      { name = "invidious"; ensureDBOwnership = true; }
      { name = "matrix-synapse"; ensureDBOwnership = true; }
      { name = "miniflux"; ensureDBOwnership = true; }
      { name = "nextcloud"; ensureDBOwnership = true; }
      { name = "vaultwarden"; ensureDBOwnership = true; }
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
}
