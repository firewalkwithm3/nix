{
  osConfig,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.window-manager.niri;
  hostName = osConfig.networking.hostName;
in
{
  options.${namespace}.window-manager.niri = with types; {
    enable = mkBoolOpt osConfig.${namespace}.desktop-environment.enable "Enable niri - window manager";
  };

  config = mkIf cfg.enable {
    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    gtk.iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };

    programs.niri.settings = mkMerge [
      {
        binds = {
          "Mod+Shift+Slash".action.show-hotkey-overlay = { };

          "Mod+Return".action.spawn = [
            "${pkgs.kitty}/bin/kitty"
            "--single-instance"
          ];

          "Mod+Space".action.spawn = "${pkgs.fuzzel}/bin/fuzzel";
          "Mod+E".action.spawn = [
            "${pkgs.bemoji}/bin/bemoji"
            "-t"
            "-c"
            "-n"
          ];

          "Mod+Shift+E".action.spawn =
            let
              power-menu = pkgs.writeShellScript "fuzzel-power-menu.sh" ''
                #!/bin/bash

                SELECTION="$(printf "󰶐  Turn off displays\n󰌾  Lock\n󰤄  Suspend\n󰍃  Log out\n󰜉  Reboot\n󰐥  Shutdown" | ${pkgs.fuzzel}/bin/fuzzel --dmenu -l 6 -p "Power Menu: ")"

                case $SELECTION in
                  *"Turn off displays")
                    ${pkgs.niri}/bin/niri msg action power-off-monitors;;
                  *"Lock")
                	  ${pkgs.gtklock}/bin/gtklock -d;;
                  *"Suspend")
                	  ${pkgs.systemd}/bin/systemctl suspend;;
                  *"Log out")
                    ${pkgs.niri}/bin/niri msg action quit;;
                  *"Reboot")
                	  ${pkgs.systemd}/bin/systemctl reboot;;
                  *"Shutdown")
                	  ${pkgs.systemd}/bin/systemctl poweroff;;
                esac
              '';
            in
            "${power-menu}";

          "Mod+P".action.screenshot-screen = { };
          "Mod+Shift+P".action.screenshot = { };
          "Mod+Ctrl+P".action.screenshot-window = { };

          "XF86AudioRaiseVolume" = {
            allow-when-locked = true;
            action.spawn = [
              "${pkgs.wireplumber}/bin/wpctl"
              "set-volume"
              "@DEFAULT_AUDIO_SINK@"
              "1%+"
            ];
          };
          "XF86AudioLowerVolume" = {
            allow-when-locked = true;
            action.spawn = [
              "${pkgs.wireplumber}/bin/wpctl"
              "set-volume"
              "@DEFAULT_AUDIO_SINK@"
              "1%-"
            ];
          };
          "XF86AudioMute" = {
            allow-when-locked = true;
            action.spawn = [
              "${pkgs.wireplumber}/bin/wpctl"
              "set-mute"
              "@DEFAULT_AUDIO_SINK@"
              "toggle"
            ];
          };
          "XF86AudioMicMute" = {
            allow-when-locked = true;
            action.spawn = [
              "${pkgs.wireplumber}/bin/wpctl"
              "set-mute"
              "@DEFAULT_AUDIO_SOURCE@"
              "toggle"
            ];
          };

          "XF86AudioPlay" = {
            allow-when-locked = true;
            action.spawn = [
              "${pkgs.playerctl}/bin/playerctl"
              "play-pause"
            ];
          };
          "XF86AudioRewind" = {
            allow-when-locked = true;
            action.spawn = [
              "${pkgs.playerctl}/bin/playerctl"
              "previous"
            ];
          };
          "XF86AudioForward" = {
            allow-when-locked = true;
            action.spawn = [
              "${pkgs.playerctl}/bin/playerctl"
              "next"
            ];
          };

          "XF86MonBrightnessDown" = {
            allow-when-locked = true;
            action.spawn = [
              "${pkgs.brillo}/bin/brillo"
              "-el"
              "-U"
              "5"
            ];
          };
          "XF86MonBrightnessUp" = {
            allow-when-locked = true;
            action.spawn = [
              "${pkgs.brillo}/bin/brillo"
              "-el"
              "-A"
              "5"
            ];
          };
          "XF86Tools" = {
            allow-when-locked = true;
            action.spawn = [
              "${pkgs.brillo}/bin/brillo"
              "-el"
              "-S"
              "100"
            ];
          };

          "XF86Display" = {
            action.spawn = "${pkgs.wdisplays}/bin/wdisplays";
          };

          "Mod+Q".action.close-window = { };

          "Mod+H".action.focus-column-or-monitor-left = { };
          "Mod+J".action.focus-window-down = { };
          "Mod+K".action.focus-window-up = { };
          "Mod+L".action.focus-column-or-monitor-right = { };

          "Mod+Shift+H".action.move-column-left-or-to-monitor-left = { };
          "Mod+Shift+J".action.move-window-down-or-to-workspace-down = { };
          "Mod+Shift+K".action.move-window-up-or-to-workspace-up = { };
          "Mod+Shift+L".action.move-column-right-or-to-monitor-right = { };

          "Mod+Tab".action.focus-monitor-next = { };

          "Mod+U".action.focus-workspace-down = { };
          "Mod+I".action.focus-workspace-up = { };

          "Mod+Shift+U".action.move-workspace-down = { };
          "Mod+Shift+I".action.move-workspace-up = { };
          "Mod+Shift+Tab".action.move-workspace-to-monitor-next = { };

          "Mod+1".action.focus-workspace = 1;
          "Mod+2".action.focus-workspace = 2;
          "Mod+3".action.focus-workspace = 3;
          "Mod+4".action.focus-workspace = 4;
          "Mod+5".action.focus-workspace = 5;
          "Mod+6".action.focus-workspace = 6;
          "Mod+7".action.focus-workspace = 7;
          "Mod+8".action.focus-workspace = 8;
          "Mod+9".action.focus-workspace = 9;
          "Mod+0".action.focus-workspace = 10;

          "Mod+Shift+1".action.move-column-to-workspace = 1;
          "Mod+Shift+2".action.move-column-to-workspace = 2;
          "Mod+Shift+3".action.move-column-to-workspace = 3;
          "Mod+Shift+4".action.move-column-to-workspace = 4;
          "Mod+Shift+5".action.move-column-to-workspace = 5;
          "Mod+Shift+6".action.move-column-to-workspace = 6;
          "Mod+Shift+7".action.move-column-to-workspace = 7;
          "Mod+Shift+8".action.move-column-to-workspace = 8;
          "Mod+Shift+9".action.move-column-to-workspace = 9;
          "Mod+Shift+0".action.move-column-to-workspace = 10;

          "Mod+BracketLeft".action.consume-or-expel-window-left = { };
          "Mod+BracketRight".action.consume-or-expel-window-right = { };
          "Mod+Comma".action.consume-window-into-column = { };
          "Mod+Period".action.expel-window-from-column = { };

          "Mod+R".action.switch-preset-column-width = { };
          "Mod+Shift+R".action.reset-window-height = { };
          "Mod+F".action.maximize-column = { };
          "Mod+Shift+F".action.fullscreen-window = { };
          "Mod+C".action.center-column = { };

          "Mod+Minus".action.set-column-width = "-10%";
          "Mod+Equal".action.set-column-width = "+10%";

          "Mod+Shift+Minus".action.set-window-height = "-10%";
          "Mod+Shift+Equal".action.set-window-height = "+10%";

          "Mod+Shift+Space".action.toggle-window-floating = { };

          "Mod+W".action.toggle-column-tabbed-display = { };

        };

        hotkey-overlay.skip-at-startup = true;
        prefer-no-csd = true;

        spawn-at-startup = [
          { command = [ "${pkgs.xwayland-satellite}/bin/xwayland-satellite" ]; }
          {
            command = [
              "${pkgs.swaybg}/bin/swaybg"
              "-o"
              "*"
              "-i"
              "${config.stylix.image}"
            ];
          }
          { command = [ "${config.programs.firefox.finalPackage}/bin/firefox" ]; }
          { command = [ "${pkgs.fractal}/bin/fractal" ]; }
          { command = [ "${pkgs.signal-desktop}/bin/signal-desktop" ]; }
          { command = [ "${pkgs.${namespace}.beeper}/bin/beeper" ]; }
          { command = [ "${pkgs.feishin}/bin/feishin" ]; }
        ];

        workspaces = {
          "01-browser" = {
            name = "browser";
            open-on-output = "Chimei Innolux Corporation 0x14F3 Unknown";
          };
          "02-work" = {
            name = "work";
            open-on-output = "Chimei Innolux Corporation 0x14F3 Unknown";
          };
          "03-games" = {
            name = "games";
            open-on-output = "Chimei Innolux Corporation 0x14F3 Unknown";
          };
          "04-media" = {
            name = "media";
            open-on-output = "Dell Inc. DELL P2018H FW7Y682903MU";
          };
          "05-chat" = {
            name = "chat";
            open-on-output = "Dell Inc. DELL P2018H FW7Y682903MU";
          };
        };

        input = {
          keyboard = {
            repeat-delay = 250;
            repeat-rate = 50;
          };
          touchpad.natural-scroll = false;
        };

        cursor = {
          hide-when-typing = true;
          theme = "Simp1e-Dark";
        };

        layout = {
          default-column-width.proportion = 1. / 2.;
          preset-column-widths = [
            { proportion = 1. / 3.; }
            { proportion = 1. / 2.; }
            { proportion = 2. / 3.; }
          ];
          gaps = 6;
          tab-indicator = {
            gap = 4;
            width = 4;
            length.total-proportion = 1. / 2.;
            position = "left";
            gaps-between-tabs = 4;
            corner-radius = 0;
          };
        };

        environment = {
          QT_QPA_PLATFORM = "wayland";
          DISPLAY = ":0";
          GTK_CSD = "0";
        };

        window-rules = [
          {
            matches = [ { app-id = "firefox"; } ];
            open-on-workspace = "browser";
            open-maximized = true;
          }
          {
            matches = [
              { app-id = "libreoffice-*"; }
              { app-id = "Gimp-*"; }
            ];
            open-on-workspace = "work";
            open-maximized = true;
          }
          {
            matches = [ { app-id = "org.prismlauncher.PrismLauncher"; } ];
            open-on-workspace = "games";
            open-maximized = true;
          }
          {
            matches = [
              { app-id = "com.github.iwalton3.jellyfin-media-player"; }
              { app-id = "feishin"; }
            ];
            open-on-workspace = "media";
            open-maximized = true;
          }
          {
            matches = [
              { app-id = "org.gnome.Fractal"; }
              { app-id = "Signal"; }
              { app-id = "Beeper"; }
            ];
            open-on-workspace = "chat";
            open-maximized = true;
          }
        ];
      }

      (mkIf config.${namespace}.apps.nextcloud.enable {
        screenshot-path = "${config.home.homeDirectory}/Nextcloud/Pictures/Screenshots/${hostName}/Screenshot from %Y-%m-%d %H-%M-%S.png";
      })
    ];
  };
}
