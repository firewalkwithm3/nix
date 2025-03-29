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
    enable = mkBoolOpt config.${namespace}.window-manager.niri.enable "Enable waybar - window manager status bar";
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
          spacing = 5;
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
          interface = "wifi";
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
          interface = "ethernet";
          tooltip = false;
          format = "󰈀";
          format-disconnected = "";
        };
        "network#tailscale" = {
          interface = "tailscale";
          tooltip = false;
          format = "󰖂";
          format-disconnected = "";
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
          tooltip-format = "BAT0: {capacity}%";
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
          tooltip-format = "BAT1: {capacity}%";
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
          "network#tailscale"
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
