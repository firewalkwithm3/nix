{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.myModule;
in
{
  options.${namespace}.myModule = with types; {
    enable = mkBoolOpt false "Enable module";
  };

  config = mkIf cfg.enable {
  };
}
