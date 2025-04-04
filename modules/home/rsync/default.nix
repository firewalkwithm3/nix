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
    enable = mkBoolOpt true "Enable rsync - file transfer utility";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      rsync
    ];
  };
}
