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
  cfg = config.${namespace}.apps.fluffychat;
in
{
  options.${namespace}.apps.fluffychat = with types; {
    enable = mkBoolOpt false "Enable the Fluffychat Matrix client";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      fluffychat
    ];
  };
}
