{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.apps.kitty;
in
{
  options.${namespace}.apps.kitty = with types; {
    enable = mkBoolOpt false "Enable Kitty terminal";
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      shellIntegration = mkIf (config.${namespace}.cli.fish.enable) {
        mode = "no-cursor";
        enableFishIntegration = true;
      };
      settings = {
        window_padding_width = 8;
        allow_remote_control = "yes";
        input_delay = 0;
        repaint_delay = 2;
        sync_to_monitor = "no";
        wayland_enable_ime = "no";
      };
    };
  };
}
