{
  # Firmware updates
  services.fwupd.enable = true;

  # CPU Microcode
  hardware.cpu.intel.updateMicrocode = true;

  # Non-free firmware
  hardware.enableRedistributableFirmware = true;
}
