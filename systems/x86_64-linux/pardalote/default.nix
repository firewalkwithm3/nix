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

    filesystems.disko.disk = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_mSATA_250GB_S41MNG0K821487A";
    services.openssh.pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIUqrhHngT/CRIjF6024MqJNy03ed7dSdKpN/7HSpToX";

    filesystems.ssd = enabled;
    firmware.intel-microcode = enabled;
    graphics.intel = enabled;
  };

  boot.initrd.availableKernelModules = [
    "ehci_pci"
    "ahci"
    "usb_storage"
    "sd_mod"
    "sdhci_pci"
  ];

  # ======================== DO NOT CHANGE THIS ========================
  system.stateVersion = "24.11";
  # ======================== DO NOT CHANGE THIS ========================
}
