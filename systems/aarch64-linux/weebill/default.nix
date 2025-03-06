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
      disk = "/dev/disk/by-id/ata-SAMSUNG_MZMTD128HAFV-000_S15MNEAD203643";
      encryption = disabled;
    };

    services.openssh.pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMOltBRuLQ7MOZK8T1aYUKdBHXcshNPv+/EMoC7lXsE7";

    filesystems.ssd = enabled;
  };

  # ======================== DO NOT CHANGE THIS ========================
  system.stateVersion = "24.11";
  # ======================== DO NOT CHANGE THIS ========================
}
