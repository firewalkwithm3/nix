{ config, hosts, ... }:
let
  hostName = config.networking.hostName;
in
{
  # LUKS Password
  age.secrets."luks_${hostName}".rekeyFile = ../../secrets/luks/${hostName}.age;

  # Partitions
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = hosts.${hostName}.installDisk;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
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
                  postCreateHook = ''
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
                    "/persist" = {
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
          };
        };
      };
    };
  };
}
