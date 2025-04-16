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
  cfg = config.${namespace}.apps.fractal;
in
{
  options.${namespace}.apps.fractal = with types; {
    enable = mkBoolOpt config.${namespace}.window-manager.niri.enable "Enable fractal - matrix client";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      fractal
    ];

    ${namespace}.impermanence.directories = [ ".local/share/fractal" ];
  };
}
