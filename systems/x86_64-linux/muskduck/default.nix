{
  namespace,
  lib,
  ...
}:
with lib;
with lib.${namespace};
{
  ${namespace} = {
    suites.laptop = enabled;

    filesystems.disko.disk = "/dev/disk/by-id/nvme-SAMSUNG_MZVLW256HEHP-000L7_S35ENA1K324390";
    services.openssh.pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICEp5zVloqXFtLEVCl44MwvdkfzIL4MsLqmENXjgPfnQ";

    bootloader.secureboot = enabled;
    filesystems.ssd = enabled;
    firmware.intel-microcode = enabled;
    graphics.intel = enabled;
    thunderbolt = enabled;
    virtualisation.qemu = enabled;
  };

  services.throttled = enabled;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # ======================== DO NOT CHANGE THIS ========================
  system.stateVersion = "24.11";
  # ======================== DO NOT CHANGE THIS ========================
}
