{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.impermanence;
  hm-cfg = config.home-manager.users.${config.${namespace}.user.name}.${namespace}.impermanence;
in
{
  options.${namespace}.impermanence = with types; {
    enable = mkBoolOpt true "Enable Impermanence";
    directories = mkOpt (listOf str) [ ] "List of system directories to persist";
    files = mkOpt (listOf str) [ ] "List of system files to persist";
  };

  config = mkIf cfg.enable {
    security.sudo.extraConfig = "Defaults lecture = never";

    environment.persistence."/persist" = {
      enable = true;
      hideMounts = true;
      directories = [
        "/var/lib/nixos"
        "/var/log"
        "/var/lib/systemd-coredump"
      ] ++ cfg.directories;

      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
      ] ++ cfg.files;

      users.${config.${namespace}.user.name} = {
        directories = [
          "Downloads"
          "git"
        ] ++ hm-cfg.directories;

        files = hm-cfg.files;
      };
    };
  };
}
