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
  cfg = config.${namespace}.cli.rsync;
in
{
  options.${namespace}.cli.rsync = with types; {
    enable = mkBoolOpt false "Enable rsync";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      rsync
    ];
  };
}
