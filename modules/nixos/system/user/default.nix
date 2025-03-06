{
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
    groups.media.enable = mkBoolOpt false "Enable the media group";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      users.mutableUsers = false;

      age.secrets."user_${hostName}".rekeyFile = ../../../../secrets/users/${hostName}.age;

      users.users.${cfg.name} = { description = cfg.fullName;
        isNormalUser = true;
        uid = 1000;
        createHome = true;
        group = "users";
        shell = mkIf (config.${namespace}.fish-shell.enable) pkgs.fish;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        openssh.authorizedKeys.keys = [
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMoJvPcUJDVVzO4dHROCFNlgJdDZSP5xyPx2s40zcx5QAAAABHNzaDo="
        ];
        hashedPasswordFile = config.age.secrets."user_${hostName}".path;
      };

      security.sudo.extraConfig = "Defaults lecture = never";
    }

    (mkIf cfg.groups.media.enable {
      users.groups.media = {
        gid = 1800;
      };
      users.users.${cfg.name}.extraGroups = [
        "media"
      ];
    })
  ]);
}
