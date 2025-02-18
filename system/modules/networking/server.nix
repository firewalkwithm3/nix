{
  imports = [ ./common.nix ];

  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-+" ];
    externalInterface = "eno1";
  };

  # Firewall
  networking.firewall.trustedInterfaces = [ "ve-+" ];

  # Podman DNS
  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

  # Enable DHCP
  networking.useDHCP = true;
}
