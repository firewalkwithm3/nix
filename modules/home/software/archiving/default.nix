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
  cfg = config.${namespace}.cli.archiving;
in
{
  options.${namespace}.cli.archiving = with types; {
    enable = mkBoolOpt false "Enable archive utilities";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      p7zip
      unrar
    ];
  };
}
