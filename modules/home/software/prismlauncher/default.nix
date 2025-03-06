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
    enable = mkBoolOpt false "Enable PrismLauncher - Minecraft client";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      prismlauncher
    ];
  };
}
