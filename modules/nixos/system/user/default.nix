{
  inputs,
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.user;
  hostName = config.networking.hostName;
in
{
  options.${namespace}.user = with types; {
    enable = mkBoolOpt true "Enable user management";
    name = mkStrOpt "fern" "Name of the (single) user";
    fullName = mkStrOpt "Fern Garden" "Full name of the user";
    email = mkStrOpt "mail@fern.garden" "Email of the user";
    users.borg = {
      enable = mkBoolOpt false "Enable the borg user for backups";
      home = mkStrOpt "/mnt/backups" "Backup directory";
    };
    groups.media.enable = mkBoolOpt false "Enable the media group";
    passwdless-sudo.enable = mkBoolOpt false "Enable passwordless sudo for users in wheel group";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      users.mutableUsers = false;
      users.defaultUserShell = mkIf (config.${namespace}.fish-shell.enable) pkgs.fish;

      age.secrets."user_${hostName}".rekeyFile = (inputs.self + "/secrets/users/${hostName}.age");

      users.users.${cfg.name} = {
        description = cfg.fullName;
        isNormalUser = true;
        useDefaultShell = true;
        uid = 1000;
        createHome = true;
        group = "users";
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        openssh.authorizedKeys.keys = [
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMoJvPcUJDVVzO4dHROCFNlgJdDZSP5xyPx2s40zcx5QAAAABHNzaDo="
        ];
        hashedPasswordFile = config.age.secrets."user_${hostName}".path;
      };
    }

    (mkIf cfg.passwdless-sudo.enable {
      security.sudo.wheelNeedsPassword = false;
    })

    (mkIf cfg.groups.media.enable {
      users.groups.media = {
        gid = 1800;
      };
      users.users.${cfg.name}.extraGroups = [
        "media"
      ];
    })

    (mkIf cfg.users.borg.enable {
      users.groups.borg = { };

      users.users.borg = {
        isSystemUser = true;
        shell = pkgs.bashInteractive;
        group = "borg";
        createHome = true;
        home = cfg.users.borg.home;
        packages = with pkgs; [ borgbackup ];
        openssh.authorizedKeys.keys = [
          inputs.self.nixosConfigurations.spoonbill.config.${namespace}.services.openssh.pubKey
        ];
      };

    })
  ]);
}
