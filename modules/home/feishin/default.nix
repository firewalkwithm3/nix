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
    enable = mkBoolOpt config.${namespace}.window-manager.niri.enable "Enable feishin - music player";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      feishin
    ];

    ${namespace}.impermanence.directories = [ ".config/feishin" ];
  };
}
