{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.suites.server;
in
{
  options.${namespace}.suites.server = with types; {
    enable = mkBoolOpt false "Enable server suite";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      networking.containers = enabled;
      nixos.timers = enabled;
      pam.rssh = enabled;
      user.passwdless-sudo = enabled;
    };
  };
}
