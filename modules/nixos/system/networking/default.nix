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
  hostName = config.networking.hostName;
in
{
  options.${namespace}.networking = with types; {
    enable = mkBoolOpt true "Enable networking";
    wifi.enable = mkBoolOpt true "Enable WiFi";
    wireguard = {
      enable = mkBoolOpt false "Enable Wireguard";
      address = mkStrOpt "" "Wireguard client address";
    };
    containers.enable = mkBoolOpt false "Enable container networking config";
    wlan-eth-bridge.enable = mkBoolOpt false "Share WiFi internet with ethernet";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      networking = {
        firewall.enable = true;
        networkmanager.enable = true;
        nftables.enable = true;
      };
    }

    (mkIf cfg.wlan-eth-bridge.enable {
      boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
      networking = {
        firewall.interfaces.end0 = {
          allowedTCPPorts = [ 53 ];
          allowedUDPPorts = [
            53
            67
          ];
        };
        interfaces.end0.ipv4.addresses = [
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
          interface = "end0";
          dhcp-range = "10.3.0.2,10.3.0.255,255.255.255.0,24h";
        };
      };
    })

    (mkIf cfg.wifi.enable {
      age.secrets.networkmanager.rekeyFile = (inputs.self + "/secrets/networking/networkmanager.age");

      systemd.network.links."81-wifi" = {
        matchConfig.Type = "wlan";
        linkConfig.Name = "wifi";
      };

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

    (mkIf cfg.wireguard.enable {
      assertions = [
        {
          assertion = cfg.wireguard.address != "";
          message = "Please provide the Wireguard client address";
        }
      ];

      networking.networkmanager.unmanaged = [ "osprey" ];

      age.secrets."wireguard_${hostName}".rekeyFile = (
        inputs.self + "/secrets/networking/wireguard/${hostName}.age"
      );

      networking.wg-quick.interfaces = {
        osprey = {
          address = [ cfg.wireguard.address ];
          dns = [ "10.0.1.1" ];
          mtu = 1380;
          privateKeyFile = config.age.secrets."wireguard_${hostName}".path;
          peers = [
            {
              publicKey = "3838nTriit2ZaqnQZykDcQEKsBBDiXPW+DUKretu9RI=";
              allowedIPs = [ "0.0.0.0/0" ];
              endpoint = "103.115.191.242:51820";
              persistentKeepalive = 25;
            }
          ];
        };
      };
    })

    (mkIf cfg.containers.enable {
      networking.nat = {
        enable = true;
        internalInterfaces = [ "ve-*" ];
        externalInterface = "eno1";
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
