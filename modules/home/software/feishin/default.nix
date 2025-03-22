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
  cfg = config.${namespace}.apps.feishin;
in
{
  options.${namespace}.apps.feishin = with types; {
    enable = mkBoolOpt false "Enable feishin - music player";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      feishin
    ];
  };
}
