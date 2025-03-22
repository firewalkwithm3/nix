{
  osConfig,
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
    enable = mkBoolOpt config.${namespace}.window-manager.niri.enable "Enable yubico-authenticator - YubiKey management application";
  };

  config = mkIf (cfg.enable && osConfig.${namespace}.yubikey.enable)  {
    home.packages = with pkgs; [
      yubioath-flutter
    ];
  };
}
