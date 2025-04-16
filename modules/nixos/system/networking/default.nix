{
  inputs,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.networking;
in
{
  options.${namespace}.networking = with types; {
    enable = mkBoolOpt true "Enable networking";
    wifi.enable = mkBoolOpt true "Enable WiFi";
    tailscale.enable = mkBoolOpt true "Enable Tailscale";
    containers.enable = mkBoolOpt false "Enable container networking config";
    wlan-eth-bridge.enable = mkBoolOpt false "Enable WiFi to ethernet bridge (ie. for sharing internet with iMac G3)";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.resolved.enable = true;

      networking = {
        networkmanager.enable = true;
        nftables.enable = true;
        firewall = {
          enable = true;
          checkReversePath = "loose";
        };
      };

      systemd.network.links = {
        "81-wifi" = {
          matchConfig.Type = "wlan";
          linkConfig.Name = "wifi";
        };
        "81-ethernet" = {
          matchConfig = {
            Type = "ether";
            Kind = "!*";
            Driver = "!rndis_host";
          };
          linkConfig.Name = "ethernet";
        };
      };
    }

    (mkIf cfg.wlan-eth-bridge.enable {
      boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
      networking = {
        firewall.interfaces.ethernet = {
          allowedTCPPorts = [ 53 ];
          allowedUDPPorts = [
            53
            67
          ];
        };

        interfaces.ethernet.ipv4.addresses = [
          {
            address = "10.3.0.1";
            prefixLength = 24;
          }
        ];

        nftables = {
          ruleset = ''
            table ip nat {
              chain POSTROUTING {
                type nat hook postrouting priority 100; policy accept;
                oifname "wifi" masquerade
              }
            }
          '';
        };
      };

      services.dnsmasq = {
        enable = true;
        settings = {
          interface = "ethernet";
          bind-interfaces = true;
          dhcp-range = "10.3.0.2,10.3.0.255,255.255.255.0,24h";
        };
      };
    })

    (mkIf cfg.wifi.enable {
      age.secrets.networkmanager.rekeyFile = (inputs.self + "/secrets/networkmanager.age");

      networking.networkmanager = {
        ensureProfiles = {
          environmentFiles = [ config.age.secrets.networkmanager.path ];
          profiles = {
            mycelium = {
              connection = {
                id = "mycelium";
                type = "wifi";
                interface-name = "wifi";
              };
              wifi = {
                mode = "infrastructure";
                ssid = "fungi 5GHz";
              };
              wifi-security = {
                auth-alg = "open";
                key-mgmt = "wpa-psk";
                psk = "$MYCELIUM_PSK";
              };
              ipv4.method = "auto";
              ipv6.method = "disabled";
            };
            flowerbed = {
              connection = {
                id = "flowerbed";
                type = "wifi";
                interface-name = "wifi";
              };
              wifi = {
                mode = "infrastructure";
                ssid = "flowerbed";
              };
              wifi-security = {
                auth-alg = "open";
                key-mgmt = "wpa-psk";
                psk = "$FLOWERBED_PSK";
              };
              ipv4.method = "auto";
              ipv6.method = "disabled";
            };
          };
        };
      };
    })

    (mkIf cfg.tailscale.enable {
      age.secrets.tailscale.rekeyFile = (inputs.self + "/secrets/tailscale.age");

      systemd.services.tailscaled.after = [ "systemd-networkd-wait-online.service" ];

      services.tailscale = {
        enable = true;
        interfaceName = "tailscale";
        authKeyFile = config.age.secrets.tailscale.path;
      };

      networking.nameservers = [
        "100.100.100.100"
        "8.8.8.8"
        "1.1.1.1"
      ];

      networking.search = [ "kingfisher-antares.ts.net" ];

      ${namespace}.impermanence.directories = [ "/var/lib/tailscale" ];
    })

    (mkIf cfg.containers.enable {
      networking.nat = {
        enable = true;
        internalInterfaces = [ "ve-*" ];
        externalInterface = "ethernet";
      };

      networking.firewall = {
        trustedInterfaces = [
          "ve-*"
          "veth*"
        ];
      };

      virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
    })
  ]);
}
