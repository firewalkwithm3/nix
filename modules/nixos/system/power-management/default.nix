{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.power-management;
in
{
  options.${namespace}.power-management = with types; {
    enable = mkBoolOpt false "Enable power management and battery management";
  };

  config = mkIf cfg.enable {
    services.thermald.enable = true;
    programs.auto-cpufreq = {
      enable = true;
      settings.battery = {
        enable_thresholds = true;
        start_threshold = 75;
        stop_threshold = 80;
        turbo = "never";
      };
    };
  };
}
