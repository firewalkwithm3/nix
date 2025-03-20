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
      suites.server = enabled;
      bootloader.raspberry-pi = enabled;
      filesystems.disko.raspberry-pi = enabled;
      networking.containers = mkDefault disabled;
    };
  };
}
