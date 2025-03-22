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
  cfg = config.${namespace}.apps.sioyek;
in
{
  options.${namespace}.apps.sioyek = with types; {
    enable = mkBoolOpt config.${namespace}.window-manager.niri.enable "Enable sioyek - PDF reader";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      sioyek
    ];
  };
}
