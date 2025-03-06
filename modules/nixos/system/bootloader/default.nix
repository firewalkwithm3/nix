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
  cfg = config.${namespace}.bootloader;
in
{
  options.${namespace}.bootloader = with types; {
    enable = mkBoolOpt true "Enable bootloader management";
    raspberry-pi.enable = mkBoolOpt false "Enable extlinux config for uboot";
    secureboot.enable = mkBoolOpt false "Enable secureboot/TPM2 with Lanzaboote";
    plymouth.enable = mkBoolOpt config.${namespace}.desktop-environment.enable "Enable splash screen";
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf config.${namespace}.impermanence.enable {
      boot.initrd.systemd = {
        initrdBin = [ pkgs.util-linux ];
        services.rollback =
          let
            rootPart =
              if config.${namespace}.filesystems.disko.encryption.enable then "/dev/mapper/crypted" else "/";
          in
          {
            description = "Rollback BTRFS root subvolume to a pristine state";
            wantedBy = [ "initrd.target" ];
            after = mkIf (config.${namespace}.filesystems.disko.encryption.enable) [
              "systemd-cryptsetup@crypted.service"
            ];
            before = [ "sysroot.mount" ];
            unitConfig.DefaultDependencies = "no";
            serviceConfig.Type = "oneshot";
            script = ''
              set -x

              # Create temporary mountpoint for rootfs subvolume
              MNTPOINT=$(mktemp -d)

              # Mount rootfs subvolume
              mount -o subvol=/ ${rootPart} $MNTPOINT

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
      };
    })

    (mkIf cfg.plymouth.enable {
      boot = {
        initrd.kernelModules = [ "i915" ];

        plymouth.enable = true;

        consoleLogLevel = 0;
        initrd.verbose = false;
        kernelParams = [
          "quiet"
          "splash"
          "boot.shell_on_fail"
          "loglevel=3"
          "rd.systemd.show_status=false"
          "rd.udev.log_level=3"
          "udev.log_priority=3"
        ];
        loader.timeout = 0;
      };
    })

    (mkIf cfg.secureboot.enable {
      boot = {
        loader = {
          efi.canTouchEfiVariables = true;
          systemd-boot.enable = mkDefault false;
        };
        bootspec.enable = true;
        initrd.systemd.enable = true;
        lanzaboote = {
          enable = true;
          pkiBundle = "/etc/secureboot";
        };
      };
    })

    (mkIf cfg.raspberry-pi.enable {
      boot.loader = {
        grub.enable = mkDefault false;
        generic-extlinux-compatible.enable = true;
      };

      boot.consoleLogLevel = lib.mkDefault 7;
      boot.kernelParams = [
        "console=ttyS0,115200n8"
        "console=ttyAMA0,115200n8"
        "console=tty0"
      ];
    })

    (mkIf (!cfg.secureboot.enable && !cfg.raspberry-pi.enable) {
      boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    })
  ]);
}
