{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.cli.openssh;
in
{
  options.${namespace}.cli.openssh = with types; {
    enable = mkBoolOpt false "Enable ssh config";
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      addKeysToAgent = "yes";
      forwardAgent = true;
    };
  };
}
