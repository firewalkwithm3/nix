{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.cli.aria2;
in
{
  options.${namespace}.cli.aria2 = with types; {
    enable = mkBoolOpt false "Enable aria2 - downloader";
  };

  config = mkIf cfg.enable {
    programs.aria2 = {
      enable = true;
      settings = {
        max-connection-per-server = 16;
        split = 16;
        max-tries = 0;
        retry-wait = 30;
      };
    };
  };
}
