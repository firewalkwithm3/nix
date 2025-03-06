{
  config,
  osConfig,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.bundles.cli;
in
{
  options.${namespace}.bundles.cli = with types; {
    enable = mkBoolOpt false "Enable CLI apps";
  };

  config = mkIf cfg.enable {
    ${namespace}.cli = {
      archiving = enabled;
      aria2 = enabled;
      fish = (mkIf osConfig.${namespace}.fish-shell.enable) enabled;
      git = enabled;
      nixvim = enabled;
      nnn = enabled;
      openssh = enabled;
      rsync = enabled;
      tmux = enabled;
      trash = enabled;
    };
  };
}
