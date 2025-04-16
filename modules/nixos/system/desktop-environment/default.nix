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
  cfg = config.${namespace}.desktop-environment;
in
{
  options.${namespace}.desktop-environment = with types; {
    enable = mkBoolOpt false "Enable a desktop environment with GDM login manager & Niri window manager";
    printing.enable = mkBoolOpt true "Enable printer support";
    scanning.enable = mkBoolOpt true "Enable scanner support";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      users.users.${config.${namespace}.user.name}.extraGroups = [
        "video"
        "input"
      ];

      services.xserver.displayManager.gdm.enable = true;

      programs.niri.enable = true;

      systemd.user.services.niri-flake-polkit = {
        wants = mkForce [ ];
        requisite = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
      };

      hardware.brillo.enable = true;
    }

    (mkIf cfg.printing.enable {
      users.users.${config.${namespace}.user.name}.extraGroups = [ "lp" ];
      services.printing = {
        enable = true;
        drivers = with pkgs; [
          brlaser
          cups-dymo
        ];
      };

      ${namespace}.impermanence = {
        directories = [ "/var/lib/cups" ];
      };

      home-manager.users.${config.${namespace}.user.name}.${namespace}.impermanence.directories = [
        ".local/share/keyrings"
      ];
    })

    (mkIf cfg.scanning.enable {
      users.users.${config.${namespace}.user.name}.extraGroups = [ "scanner" ];
      hardware.sane.enable = true;
    })
  ]);
}
