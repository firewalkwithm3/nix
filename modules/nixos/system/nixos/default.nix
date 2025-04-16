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
  cfg = config.${namespace}.nixos;
in
{
  options.${namespace}.nixos = with types; {
    enable = mkBoolOpt true "Set NixOS settings";
    timers.enable = mkBoolOpt false "Enable automatic services (autoupgrade, garbage collection, store optimisation)";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      environment.systemPackages = with pkgs; [ snowfallorg.flake ];

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      nix.settings.trusted-users = [ "fern" ];

      programs.nix-index-database.comma.enable = true;
    }

    (mkIf cfg.timers.enable {
      system.autoUpgrade = {
        enable = true;
        dates = "3:00";
        flake = "github:firewalkwithm3/nix";
      };

      nix.gc = {
        automatic = true;
        dates = "Mon *-*-* 04:00:00";
        options = "--delete-older-than 7d";
      };

      nix.optimise = {
        automatic = true;
        dates = [ "Mon *-*-* 05:00:00" ];
      };
    })
  ]);
}
