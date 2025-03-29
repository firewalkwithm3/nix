{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.suites.laptop;
in
{
  options.${namespace}.suites.laptop = with types; {
    enable = mkBoolOpt false "Enable laptop suite";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      desktop-environment = enabled;
      yubikey = enabled;
      power-management = enabled;
    };
  };
}
