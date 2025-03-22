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
  cfg = config.${namespace}.apps.prismlauncher;
in
{
  options.${namespace}.apps.prismlauncher = with types; {
    enable = mkBoolOpt config.${namespace}.window-manager.niri.enable "Enable prismlauncher - Minecraft client";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      prismlauncher
    ];
  };
}
