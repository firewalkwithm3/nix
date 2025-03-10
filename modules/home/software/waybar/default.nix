{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.window-manager.waybar;
in
{
  options.${namespace}.window-manager.waybar = with types; {
    enable = mkBoolOpt false "Enable waybar";
  };

  config = mkIf cfg.enable {
    systemd.user.services.waybar.Unit = {
      After = mkForce [ "graphical-session.target" ];
      Requisite = mkForce [ "graphical-session.target" ];
    };

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings.main = {
        "tray" = {
          icon-size = 13;
        };
        "idle_inhibitor" = {
          tooltip = false;
          format = "{icon}";
          format-icons = {
            activated = "󰅶";
            deactivated = "󰒲";
          };
        };
        "niri/workspaces" = {
          format = "{icon}";
          format-icons = {
            browser = "󰈹";
            work = "󰈙";
            games = "󰊗";
            media = "󰝚";
            chat = "󰭹";
            default = "";
          };
        };
        "network#wifi" = {
          interface = "wlp3s0";
          tooltip = true;
          tooltip-format = "{essid}";
          format = "{icon}";
          format-disconnected = "";
          format-icons = [
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
        };
        "network#eth" = {
          interface = "enp0s31f6";
          tooltip = false;
          format = "󰈀";
          format-disconnected = "";
          on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
        };
        "network#wireguard" = {
          interface = "forest";
          tooltip = false;
          format = "󰖂";
          format-disconnected = "";
          on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
        };
        "clock" = {
          tooltip = true;
          tooltip-format = "{:%A %d %B}";
          format = "󰥔  {:%H:%M}";
          timezone = "Australia/Perth";
        };
        "wireplumber" = {
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol -t 3";
          tooltip = false;
          format = "{icon} {volume}%";
          format-muted = "󰝟";
          format-icons = [
            "󰕿"
            "󰖀"
            "󰕾"
          ];
        };
        "battery#bat0" = {
          bat = "BAT0";
          tooltip = true;
          tooltip-format = "Internal: {capacity}%";
          states = {
            warning = 30;
            critical = 15;
          };
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          format = "{icon}";
          format-charging = "󰂄";
        };
        "battery#bat1" = {
          bat = "BAT1";
          tooltip = true;
          tooltip-format = "External: {capacity}%";
          states = {
            warning = 30;
            critical = 15;
          };
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          format = "{icon}";
          format-charging = "󰂄";
        };

        layer = "top";
        position = "top";
        modules-left = [ "niri/workspaces" ];
        modules-right = [
          "tray"
          "idle_inhibitor"
          "network#wireguard"
          "network#eth"
          "network#wifi"
          "battery#bat0"
          "battery#bat1"
          "wireplumber"
          "clock"
        ];
      };
    };
  };
}
