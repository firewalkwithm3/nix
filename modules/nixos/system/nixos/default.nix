{
  config,
  lib,
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
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      nix.settings.trusted-users = [ "fern" ];
    }

    (mkIf cfg.timers.enable {
      systemd.extraConfig = "DefaultLimitNOFILE=2048";

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
