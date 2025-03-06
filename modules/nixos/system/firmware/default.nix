{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.firmware;
in
{
  options.${namespace}.firmware = {
    enable = mkBoolOpt true "Enable updating firmware & non-free firmware";
    intel-microcode.enable = mkBoolOpt false "Enable intel microcode updates";
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.intel-microcode.enable {
      hardware.cpu.intel.updateMicrocode = true;
    })

    {
      services.fwupd.enable = true;
      hardware.enableRedistributableFirmware = true;
    }
  ]);
}
