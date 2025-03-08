{
  inputs,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.filesystems;
  hostName = config.networking.hostName;
in
{
  options.${namespace}.filesystems = {
    rclone.enable = mkBoolOpt false "Enable rclone drives";
    ssd.enable = mkBoolOpt false "Enable SSD options";
    disko = with types; {
      enable = mkBoolOpt true "Allow disko to manage partitions and mounts";
      encryption.enable = mkBoolOpt true "Enable LUKS encryption";
      disk = mkStrOpt "" "Disk to install NixOS to";
      raspberry-pi.enable = mkBoolOpt false "Enable Raspberry Pi disk layout";
      impermanence.enable =
        mkBoolOpt config.${namespace}.impermanence.enable
          "Whether to enable impermanent rootfs";
    };
  };

  config = mkMerge [
    {
      services.udisks2.enable = true;
      zramSwap.enable = true;
    }

    (mkIf cfg.ssd.enable {
      services.fstrim.enable = true;
    })

    (mkIf cfg.rclone.enable {
      environment.systemPackages = [ pkgs.rclone ];
      age.secrets.rclone.rekeyFile = (inputs.self + "/secrets/rclone.age");
      environment.etc."rclone.conf".source = config.age.secrets.rclone.path;

      fileSystems."/mnt/onedrive" = {
        device = "onedrive:/";
        fsType = "rclone";
        options = [
          "nodev"
          "nofail"
          "allow_other"
          "args2env"
          "config=/etc/rclone.conf"
        ];
      };
    })

    (mkIf cfg.disko.encryption.enable {
      age.secrets."luks_${hostName}".rekeyFile = (inputs.self + "/secrets/luks/${hostName}.age");
    })

    (mkIf cfg.disko.impermanence.enable {
      fileSystems."/persist".neededForBoot = true;
    })

    (mkIf cfg.disko.raspberry-pi.enable {
      boot.postBootCommands = ''
        # On the first boot, resize the disk
        if [ -f /disko-first-boot ]; then
          set -euo pipefail
          set -x
          # Figure out device names for the boot device and root filesystem.
          rootPart=$(${pkgs.util-linux}/bin/findmnt -v -n -o SOURCE /)
          bootDevice=$(lsblk -npo PKNAME $rootPart)
          partNum=$(lsblk -npo MAJ:MIN $rootPart | ${pkgs.gawk}/bin/awk -F: '{print $2}')

          # Resize the root partition and the filesystem to fit the disk
          echo ",+," | sfdisk -N$partNum --no-reread $bootDevice
          ${pkgs.parted}/bin/partprobe

          # Prevents this from running on later boots.
          rm -f /disko-first-boot
        fi
      '';
    })

    (mkIf cfg.disko.enable {
      assertions = [
        {
          assertion = cfg.disko.disk != "";
          message = "Please provide the installation disk";
        }
      ];

      disko = {
        devices.disk.main = {
          type = "disk";
          device = cfg.disko.disk;
          content = {
            type = "gpt";
            partitions = mkMerge [
              {
                boot = {
                  size = "512M";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [ "umask=0077" ];
                  };
                };
              }

              (
                let
                  configTxt = pkgs.writeText "config.txt" ''
                    [pi4]
                    kernel=u-boot-rpi4.bin
                    enable_gic=1

                    # Otherwise the resolution will be weird in most cases, compared to
                    # what the pi3 firmware does by default.
                    disable_overscan=1

                    # Supported in newer board revisions
                    arm_boost=1

                    [cm4]
                    # Enable host mode on the 2711 built-in XHCI USB controller.
                    # This line should be removed if the legacy DWC2 controller is required
                    # (e.g. for USB device mode) or if USB support is not required.
                    otg_mode=1

                    [all]
                    # Boot in 64-bit mode.
                    arm_64bit=1

                    # U-Boot needs this to work, regardless of whether UART is actually used or not.
                    # Look in arch/arm/mach-bcm283x/Kconfig in the U-Boot tree to see if this is still
                    # a requirement in the future.
                    enable_uart=1

                    # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
                    # when attempting to show low-voltage or overtemperature warnings.
                    avoid_warnings=1
                  '';
                in
                mkIf cfg.disko.raspberry-pi.enable {
                  firmware = {
                    size = "30M";
                    priority = 1;
                    type = "0700";
                    content = {
                      type = "filesystem";
                      format = "vfat";
                      mountpoint = "/firmware";
                      postMountHook = toString (
                        pkgs.writeScript "postMountHook.sh" ''
                          (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf *.dtb /mnt/firmware/)
                          cp ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin /mnt/firmware/u-boot-rpi4.bin
                          cp ${configTxt} /mnt/firmware/config.txt
                        ''
                      );
                    };
                  };
                }
              )

              (mkIf cfg.disko.encryption.enable {
                luks = {
                  size = "100%";
                  content = {
                    type = "luks";
                    name = "crypted";
                    passwordFile = "/tmp/luks.key";
                    settings = {
                      allowDiscards = true;
                    };
                    content = {
                      type = "btrfs";
                      extraArgs = [ "-f" ];
                      postMountHook = mkIf cfg.disko.raspberry-pi.enable "touch /mnt/disko-first-boot";
                      postCreateHook = mkIf cfg.disko.impermanence.enable ''
                        MNTPOINT=$(mktemp -d)
                        mount "/dev/mapper/crypted" "$MNTPOINT" -o subvol=/
                        trap 'umount $MNTPOINT; rm -rf $MNTPOINT' EXIT
                        btrfs subvolume snapshot -r $MNTPOINT/rootfs $MNTPOINT/rootfs-blank
                      '';
                      subvolumes = {
                        "rootfs" = {
                          mountpoint = "/";
                          mountOptions = [
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "/nix" = {
                          mountpoint = "/nix";
                          mountOptions = [
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "/persist" = mkIf cfg.disko.impermanence.enable {
                          mountpoint = "/persist";
                          mountOptions = [
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                      };
                    };
                  };
                };
              })

              (mkIf (!cfg.disko.encryption.enable) {
                root.content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  postCreateHook = mkIf cfg.disko.impermanence.enable ''
                    MNTPOINT=$(mktemp -d)
                    mount "/dev/disk/by-partlabel/disk-main-root" "$MNTPOINT" -o subvol=/
                    trap 'umount $MNTPOINT; rm -rf $MNTPOINT' EXIT
                    btrfs subvolume snapshot -r $MNTPOINT/rootfs $MNTPOINT/rootfs-blank
                  '';
                  subvolumes = {
                    "rootfs" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/persist" = mkIf cfg.disko.impermanence.enable {
                      mountpoint = "/persist";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                  };
                };
              })
            ];
          };
        };
      };
    })
  ];
}
