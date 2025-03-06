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
  cfg = config.${namespace}.home-manager;
in
{
  options.${namespace}.home-manager = with types; {
    enable = mkBoolOpt true "Enable home dir management with home-manager";
  };

  config = mkIf cfg.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm_backup";
      users.${config.${namespace}.user.name}.programs.niri.package = pkgs.niri;
    };
  };
}
