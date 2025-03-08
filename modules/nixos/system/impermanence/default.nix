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
  hm-cfg = config.home-manager.users.${config.${namespace}.user.name}.${namespace};
in
{
  options.${namespace}.impermanence = with types; {
    enable = mkBoolOpt true "Enable Impermanence";
  };

  config = mkIf cfg.enable {
    security.sudo.extraConfig = "Defaults lecture = never";

    environment.persistence."/persist" = {
      enable = true;
      hideMounts = true;
      directories = mkMerge [
        [
          "/var/lib/nixos"
          "/var/log"
          "/var/lib/systemd-coredump"
        ]

        (mkIf config.${namespace}.thunderbolt.enable [
          "/var/lib/boltd"
        ])

        (mkIf config.${namespace}.bootloader.secureboot.enable [
          "/etc/secureboot"
        ])

        (mkIf config.${namespace}.services.netatalk.enable [
          "/var/srv/iMacG3"
        ])
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];
      users.${config.${namespace}.user.name} = {
        directories = mkMerge [
          [
            "Downloads"
            "git"
            ".local/share/keyrings"
          ]

          (mkIf hm-cfg.apps.prismlauncher.enable [
            ".local/share/PrismLauncher"
          ])

          (mkIf hm-cfg.apps.signal.enable [
            ".config/Signal"
          ])

          (mkIf hm-cfg.apps.fluffychat.enable [
            ".local/share/chat.fluffy.fluffychat"
          ])

          (mkIf hm-cfg.apps.feishin.enable [
            ".config/feishin"
          ])

          (mkIf hm-cfg.apps.firefox.enable [
            ".mozilla"
          ])

          (mkIf hm-cfg.apps.nextcloud.enable [
            "Nextcloud"
          ])
        ];
        files = mkMerge [
          (mkIf hm-cfg.window-manager.fuzzel.enable [
            ".local/share/bemoji/emojis.txt"
          ])
        ];
      };
    };
  };
}
