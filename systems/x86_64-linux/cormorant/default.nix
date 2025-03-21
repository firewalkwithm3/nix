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

    filesystems.disko.disk = "/dev/disk/by-id/ata-Seagate_BarraCuda_120_SSD_ZA500CM10003_7QV02WWP";
    services.openssh.pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII005DpMxMfjOygHCG3IFY8uq/N5NOoysJO9E/+x6kfw";

    filesystems.ssd = enabled;
    firmware.intel-microcode = enabled;
    graphics.intel = enabled;

    networking.wlan-eth-bridge = enabled;

    services = {
      netatalk = enabled;
      webone = enabled;
    };
  };

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "usb_storage"
    "sd_mod"
  ];

  # ======================== DO NOT CHANGE THIS ========================
  system.stateVersion = "24.11";
  # ======================== DO NOT CHANGE THIS ========================
}
