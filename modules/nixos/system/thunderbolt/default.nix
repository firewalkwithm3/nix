{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.thunderbolt;
in
{
  options.${namespace}.thunderbolt = with types; {
    enable = mkBoolOpt false "Enable Thunderbolt support";
  };

  config = mkIf cfg.enable {
    services.hardware.bolt.enable = true;
    ${namespace} = {
      udev.thunderbolt.enable = true;
      impermanence.directories = [ "/var/lib/boltd" ];
    };
  };
}
