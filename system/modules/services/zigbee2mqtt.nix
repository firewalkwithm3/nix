{ config, lib, ... }:
{
  age.secrets.mqtt = {
    rekeyFile = ../../../secrets/services/mqtt.age;
    owner = "mosquitto";
    group = "mosquitto";
  };

  age.secrets."z2m.yaml" = {
    rekeyFile = ../../../secrets/services/z2m.age;
    owner = "zigbee2mqtt";
    group = "zigbee2mqtt";
  };

  services.mosquitto = {
    enable = true;
    logType = [ "all" ];
    listeners = [
      {
        users.z2m = {
          passwordFile = config.age.secrets.mqtt.path;
          acl = [
            "readwrite #"
          ];
        };
        address = "127.0.0.1";
      }
    ];
  };

  services.zigbee2mqtt = {
    enable = true;
    settings = {
      permit_join = false;
      serial = {
        port = "/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0";
        adaptor = "zstack";
      };
      advanced = {
        rtscts = false;
        homeassistant_legacy_entity_attributes = false;
        homeassistant_legacy_triggers = false;
        legacy_api = false;
        legacy_availability_payload = false;
      };
      device_options.legacy = false;
      frontend = {
        enabled = true;
        port = 1884;
        host = "127.0.0.1";
      };
      mqtt = {
        server = "mqtt://127.0.0.1:1883";
        base_topic = "zigbee2mqtt";
        user = "z2m";
        password = "!${config.age.secrets."z2m.yaml".path} password";
      };
      homeassistant = {
        enabled = true;
        discovery_topic = "homeassistant";
        status_topic = "homeassistant/status";
      };
    };
  };

  services.caddy.virtualHosts."z2m.ferngarden.net" = {
    logFormat = lib.mkForce "output discard";
    extraConfig = "reverse_proxy 127.0.0.1:1884";
  };
}
