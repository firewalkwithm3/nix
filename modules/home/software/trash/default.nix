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
  cfg = config.${namespace}.cli.trash;
in
{
  options.${namespace}.cli.trash = with types; {
    enable = mkBoolOpt false "Enable trash";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      trash-cli
    ];
  };
}
