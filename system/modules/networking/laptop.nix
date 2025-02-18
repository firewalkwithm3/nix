{ config, hosts, ... }:
let
  hostName = config.networking.hostName;
in
{
  imports = [ ./common.nix ];

  # PSKs
  age.secrets.networkmanager.rekeyFile = ../../../secrets/networking/networkmanager.age;

  # WiFi
  networking.networkmanager = {
    enable = true;
    unmanaged = [ "forest" ];
    ensureProfiles = {
      environmentFiles = [ config.age.secrets.networkmanager.path ];
      profiles = {
        mycelium = {
          connection = {
            id = "mycelium";
            type = "wifi";
            interface-name = "wlp3s0";
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
            interface-name = "wlp3s0";
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

  # VPN
  age.secrets."wireguard_${hostName}".rekeyFile = ../../../secrets/networking/wireguard/${hostName}.age;

  networking.wg-quick.interfaces = {
    forest = {
      address = [ hosts.${hostName}.wg_address ];
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
}
