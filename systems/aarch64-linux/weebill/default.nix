{
  namespace,
  lib,
  ...
}:
with lib;
with lib.${namespace};
{
  ${namespace} = {
    suites.rpi = enabled;

    filesystems.disko = {
      disk = "/dev/disk/by-id/mmc-SK32G_0xc4ee9443";
      encryption = disabled;
    };

    services.openssh.pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMOltBRuLQ7MOZK8T1aYUKdBHXcshNPv+/EMoC7lXsE7";

    filesystems.ssd = enabled;

    user.users.borg = enabled;

    networking.wlan-eth-bridge = enabled;

    services = {
      netatalk = enabled;
      webone = enabled;
    };
  };

  fileSystems."/mnt" = {
    device = "/dev/disk/by-id/usb-Seagate_Expansion_HDD_00000000NACVB7BG-0:0-part1";
    fsType = "ext4";
  };

  # ======================== DO NOT CHANGE THIS ========================
  system.stateVersion = "24.11";
  # ======================== DO NOT CHANGE THIS ========================
}
