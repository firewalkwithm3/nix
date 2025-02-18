{
  imports = [
    ./hardware-configuration.nix
    ../../roles/server.nix

    ../../modules/secureboot.nix
  ];

  # Hostname
  networking.hostName = "forest";

  # Filesystems
  fileSystems."/mnt/volume1" = {
    device = "/dev/disk/by-uuid/5d9dd538-79e4-4168-be91-e0b040155cb3";
    fsType = "ext4";
  };

  fileSystems."/mnt/volume2" = {
    device = "/dev/disk/by-uuid/5a43b7dc-3e28-459e-824a-ad45b5475361";
    fsType = "ext4";
  };

  fileSystems."/mnt/volume3" = {
    device = "/dev/disk/by-uuid/fcee0188-8ca1-4fda-81b7-f5920c79ab48";
    fsType = "ext4";
  };
}
