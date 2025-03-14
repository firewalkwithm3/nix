{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.suites.rpi;
in
{
  options.${namespace}.suites.rpi = with types; {
    enable = mkBoolOpt false "Enable Raspberry Pi suite";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      bootloader.raspberry-pi = enabled;
      filesystems.disko.raspberry-pi = enabled;
      networking = {
        wifi = enabled;
        wlan-eth-bridge = enabled;
      };
      nixos.timers = enabled;
      pam.rssh = enabled;
      user.passwdless-sudo = enabled;

      services = {
        netatalk = enabled;
        webone = enabled;
      };
    };
  };
}
