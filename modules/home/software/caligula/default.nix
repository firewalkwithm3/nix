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
  cfg = config.${namespace}.cli.caligula;
in
{
  options.${namespace}.cli.caligula = with types; {
    enable = mkBoolOpt false "Enable Caligula disk writer";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      caligula
    ];
  };
}
