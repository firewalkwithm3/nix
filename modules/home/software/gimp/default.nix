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
  cfg = config.${namespace}.apps.gimp;
in
{
  options.${namespace}.apps.gimp = with types; {
    enable = mkBoolOpt false "Enable the GNU Image Manipulation program";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gimp
    ];
  };
}
