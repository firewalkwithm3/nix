{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.udev;
in
{
  options.${namespace}.udev = with types; {
    enable = mkBoolOpt true "Enable udev rules";
    nintendo-switch.enable =
      mkBoolOpt config.${namespace}.desktop-environment.enable
        "Enable udev rule for Nintendo Switch";
    thunderbolt.enable =
      mkBoolOpt config.${namespace}.thunderbolt.enable
        "Enable rescanning of PCI devices when Thunderbolt dock is reconnected";
    yubikey.enable = mkBoolOpt config.${namespace}.yubikey.enable "Enable YubiKey packages";
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.nintendo-switch.enable {
      services.udev.extraRules = ''
        # Nintendo Switch
        SUBSYSTEM=="usb", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="3000", GROUP="users"
      '';
    })

    (mkIf cfg.thunderbolt.enable {
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="thunderbolt", RUN+="${pkgs.coreutils}/bin/echo 1 > /sys/bus/pci/rescan"
      '';
    })

    (mkIf cfg.yubikey.enable {
      services.udev.packages = with pkgs; [
        yubikey-personalization
        libu2f-host
      ];
    })
  ]);
}
