{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.apps.imv;
in
{
  options.${namespace}.apps.imv = with types; {
    enable = mkBoolOpt false "Enable the imv image viewer";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      imv
    ];
  };
}
