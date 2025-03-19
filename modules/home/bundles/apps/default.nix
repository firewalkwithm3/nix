{
  config,
  osConfig,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.bundles.apps;
in
{
  options.${namespace}.bundles.apps = with types; {
    enable = mkBoolOpt false "Enable GUI apps";
  };

  config = mkIf cfg.enable {
    ${namespace}.apps = {
      feishin = enabled;
      firefox = enabled;
      cinny = enabled;
      gimp = enabled;
      imv = enabled;
      kitty = enabled;
      libreoffice = enabled;
      mpv = enabled;
      nextcloud = enabled;
      prismlauncher = enabled;
      signal = enabled;
      sioyek = enabled;
      virt-manager = (mkIf osConfig.${namespace}.virtualisation.qemu.enable) enabled;
      yubico-authenticator = (mkIf osConfig.${namespace}.yubikey.enable) enabled;
    };
  };
}
