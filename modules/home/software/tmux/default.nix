{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.cli.tmux;
in
{
  options.${namespace}.cli.tmux = with types; {
    enable = mkBoolOpt false "Enable tmux - terminal multiplexer";
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      keyMode = "vi";
      mouse = true;
      newSession = true;
      terminal = "screen-256color";
    };
  };
}
