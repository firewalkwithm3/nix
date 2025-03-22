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
  cfg = config.${namespace}.apps.cinny;
in
{
  options.${namespace}.apps.cinny = with types; {
    enable = mkBoolOpt false "Enable cinny - matrix client";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      cinny
    ];
  };
}
