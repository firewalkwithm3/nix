{
  imports = [
    # system config
    ../modules/bootloader.nix
    ../modules/cmdline-shell.nix
    ../modules/filesystems.nix
    ../modules/firmware.nix
    ../modules/stylix.nix
    ../modules/locale.nix
    ../modules/intel-graphics.nix
    ../modules/nixos.nix
    ../modules/ssd.nix
    ../modules/zram.nix
    ../modules/agenix
    ../modules/pam

    # services
    ../modules/services/openssh.nix
  ];
}
