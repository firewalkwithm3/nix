{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.fish-shell;
in
{
  options.${namespace}.fish-shell = with types; {
    enable = mkBoolOpt true "Enable fish shell";
  };

  config = mkIf cfg.enable {
    programs.fish.enable = true;
    documentation.man.generateCaches = false;
  };
}
