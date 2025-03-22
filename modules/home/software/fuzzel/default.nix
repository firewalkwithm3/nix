{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.window-manager.fuzzel;
in
{
  options.${namespace}.window-manager.fuzzel = with types; {
    enable = mkBoolOpt false "Enable fuzzel - application launcher";
  };

  config = mkIf cfg.enable {
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          layer = "overlay";
          dpi-aware = "no";
          lines = 12;
          line-height = 12;
          width = 40;
          tabs = 2;
          horizontal-pad = 8;
          vertical-pad = 8;
          inner-pad = 4;
        };
        border = {
          width = 1;
          radius = 0;
        };
      };
    };
  };
}
