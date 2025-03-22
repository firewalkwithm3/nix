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
    enable =
      mkBoolOpt config.${namespace}.window-manager.niri.enable
        "Enable kitty - terminal emulator";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.kitty = {
        enable = true;
        settings = {
          window_padding_width = 8;
          allow_remote_control = "yes";
          input_delay = 0;
          repaint_delay = 2;
          sync_to_monitor = "no";
          wayland_enable_ime = "no";
        };
      };
    }

    (mkIf config.${namespace}.cli.fish.enable {
      programs.kitty.shellIntegration = {
        mode = "no-cursor";
        enableFishIntegration = true;
      };
    })
  ]);
}
