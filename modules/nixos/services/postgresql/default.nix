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

  mkUsers =
    modules:
    map (db: {
      name = db;
      ensureDBOwnership = true;
    }) modules;
in
{
  options.${namespace}.services.postgres = with types; {
    enable = mkBoolOpt false "Enable postgres - database";
    databases = mkOpt (listOf str) [ ] "List of databases to be created for this module";
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_16;
      ensureDatabases = cfg.databases;
      ensureUsers = mkUsers cfg.databases;
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
