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
      systemd.extraConfig = "DefaultLimitNOFILE=2048";

      system.autoUpgrade = {
        enable = true;
        dates = "3:00";
        flake = "github:firewalkwithm3/nix";
      };

      systemd.services.nixos-upgrade.onFailure = [ "notify-failure@nixos-upgrade.service" ];

      systemd.services."notify-failure@" = {
        enable = true;
        description = "Failure notification for %i";
        scriptArgs = ''"%i" "Hostname: %H" "Machine ID: %m" "Boot ID: %b"'';
        script = ''
          unit="$1"
          extra_information=""
          for e in "''${@:2}"; do
            extra_information+="$e"$'\n'
          done
          ${pkgs.mailutils}/bin/mail \
          --subject="Service $unit failed on $2" \
          --return-address="mail@ferngarden.net" \
          recipient@example.com \
          <<EOF
          $(systemctl status -n 1000000 "$unit")
          $extra_information
          EOF
        '';
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
