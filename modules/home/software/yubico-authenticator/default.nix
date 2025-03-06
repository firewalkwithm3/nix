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
  cfg = config.${namespace}.apps.yubico-authenticator;
in
{
  options.${namespace}.apps.yubico-authenticator = with types; {
    enable = mkBoolOpt false "Enable Yubico Authenticator";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      yubioath-flutter
    ];
  };
}
