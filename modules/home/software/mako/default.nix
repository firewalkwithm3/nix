{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.window-manager.mako;
in
{
  options.${namespace}.window-manager.mako = with types; {
    enable = mkBoolOpt false "Enable mako notification daemon";
  };

  config = mkIf cfg.enable {
    services.mako = {
      enable = true;
      layer = "overlay";
      defaultTimeout = 10000;
      padding = "20";
      margin = "6";
      borderSize = 1;
    };
  };
}
