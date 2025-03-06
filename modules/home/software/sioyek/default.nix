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
    enable = mkBoolOpt false "Enable the sioyek PDF reader";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      sioyek
    ];
  };
}
