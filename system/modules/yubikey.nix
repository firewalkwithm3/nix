{
  pkgs,
  ...
}:
{
  # Enable Yubikey support
  services.udev.packages = [
    pkgs.yubikey-personalization
    pkgs.libu2f-host
  ];

  services.pcscd.enable = true;
}
