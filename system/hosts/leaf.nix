{
  imports = [
    ../roles/laptop.nix
  ];

  # Hostname
  networking.hostName = "leaf";

  # Kernel modules
  boot.initrd.availableKernelModules = [
    "ehci_pci"
    "ahci"
    "usb_storage"
    "sd_mod"
    "sdhci_pci"
  ];
}
