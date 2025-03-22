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
  cfg = config.${namespace}.apps.signal;
in
{
  options.${namespace}.apps.signal = with types; {
    enable = mkBoolOpt false "Enable signal - encrypted messenger";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      signal-desktop
    ];
  };
}
