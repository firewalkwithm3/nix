{
  imports = [
    ../roles/laptop.nix

    ../modules/secureboot.nix
    ../modules/thunderbolt.nix
    ../modules/virtualisation.nix
  ];

  # Hostname, host id
  networking.hostName = "garden";

  # Fix throttling issue on T480
  services.throttled.enable = true;

  # Kernel modules
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
}
