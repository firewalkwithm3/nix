{ options, ... }:
{
  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/lib/nixos"
      "/var/log"
      "/var/lib/systemd-coredump"
      "/etc/NetworkManager/system-connections"
      "/etc/secureboot"
      "/var/lib/boltd"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
    users.fern = {
      directories = [
        "Downloads"
        "git"
        "Nextcloud"
        ".config/feishin"
        ".config/Signal"
        ".local/share/chat.fluffy.fluffychat"
        ".local/share/keyrings"
        ".local/share/PrismLauncher"
        ".mozilla"
      ];
      files = [
        ".local/share/bemoji/emojis.txt"
      ];
    };
  };

  # /persist need to exist early in boot for ssh keys
  fileSystems."/persist".neededForBoot = true;
  age.identityPaths = options.age.identityPaths.default ++ [
    "/persist/etc/ssh/ssh_host_ed25519_key"
  ];

  # Disable sudo lecture
  security.sudo.extraConfig = "Defaults lecture = never";

  # Rollback service
  boot.initrd.systemd.services.rollback = {
    description = "Rollback BTRFS root subvolume to a pristine state";
    wantedBy = [ "initrd.target" ];
    after = [ "systemd-cryptsetup@crypted.service" ];
    before = [ "sysroot.mount" ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      # Create temporary mountpoint for rootfs subvolume
      MNTPOINT=$(mktemp -d)

      # Mount rootfs subvolume
      mount -o subvol=/ /dev/mapper/crypted $MNTPOINT

      # Delete children of rootfs subvolume
      btrfs subvolume list -o $MNTPOINT/rootfs |
      cut -f9 -d' ' |
      while read subvolume; do
        echo "Deleting /$subvolume subvolume..."
        btrfs subvolume delete "$MNTPOINT/$subvolume"
      done &&

      # Delete rootfs subvolume
      echo "Deleting rootfs subvolume..." &&
      btrfs subvolume delete $MNTPOINT/rootfs

      # Restore blank snapshot of rootfs
      echo "Restoring blank rootfs subvolume..."
      btrfs subvolume snapshot $MNTPOINT/rootfs-blank $MNTPOINT/rootfs

      # Unmount rootfs subvolume
      umount $MNTPOINT
    '';
  };
}
