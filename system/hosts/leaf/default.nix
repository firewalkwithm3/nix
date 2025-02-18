{
  imports = [
    ./hardware-configuration.nix
    ../../roles/laptop.nix
  ];

  # Hostname
  networking.hostName = "leaf";
}
