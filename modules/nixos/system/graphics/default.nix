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
  cfg = config.${namespace}.graphics;
in
{
  options.${namespace}.graphics = with types; {
    intel.enable = mkBoolOpt false "Enable Intel graphics";
  };

  config = mkIf cfg.intel.enable {
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        intel-compute-runtime
      ];
    };
  };
}
