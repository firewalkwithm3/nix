{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.yubikey;
in
{
  options.${namespace}.yubikey = with types; {
    enable = mkBoolOpt false "Enable YubiKey support";
  };

  config = mkIf cfg.enable {
    services.pcscd.enable = true;
  };
}
