{
  namespace,
  lib,
  ...
}:
with lib;
with lib.${namespace};
{
  ${namespace} = {
    suites.server = enabled;

    filesystems.disko = disabled;
    impermanence = disabled;
    #filesystems.disko.disk = "/dev/disk/by-id/nvme-SAMSUNG_MZVLW256HEHP-000L7_S35ENA1K324390";
    services.openssh.pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINLhv0WaxWuQhBb3BG4wrebkb+egB2hdeysbODTGXSSQ";

    bootloader.secureboot = enabled;
    filesystems.ssd = enabled;
    filesystems.rclone = enabled;
    networking.wifi = disabled;
    firmware.intel-microcode = enabled;
    graphics.intel = enabled;

    user.groups.media = enabled;

    services = {
      audiobookshelf = enabled;
      bazarr = enabled;
      borgmatic = enabled;
      caddy = enabled;
      calibre = enabled;
      forgejo = enabled;
      home-assistant = enabled;
      immich = enabled;
      jellyfin = enabled;
      jellyseerr = enabled;
      lidarr = enabled;
      mailserver = enabled;
      matrix-synapse = enabled;
      memos = enabled;
      minecraft = enabled;
      miniflux = enabled;
      navidrome = enabled;
      nextcloud = enabled;
      ntfy = enabled;
      pinchflat = enabled;
      pixelfed = enabled;
      paperless = enabled;
      postgres = enabled;
      priviblur = enabled;
      prowlarr = enabled;
      qbittorrent = enabled;
      radarr = enabled;
      readarr-audiobooks = enabled;
      readarr-ebooks = enabled;
      sonarr = enabled;
      vaultwarden = enabled;
      wallos = enabled;
      tailscale-exit-node = enabled;
    };
  };

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sr_mod"
  ];

  boot.initrd.luks.devices."luks-f9886850-2e74-4815-9983-78d1af78157d".device =
    "/dev/disk/by-uuid/f9886850-2e74-4815-9983-78d1af78157d";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/5612505a-3d8c-4e5f-b817-3eeb50c0d44a";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C966-9388";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

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

  # ======================== DO NOT CHANGE THIS ========================
  system.stateVersion = "24.11";
  # ======================== DO NOT CHANGE THIS ========================
}
