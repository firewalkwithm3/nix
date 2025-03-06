{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.openssh;
  hostName = config.networking.hostName;
in
{
  options.${namespace}.services.openssh = with types; {
    enable = mkBoolOpt true "Enable SSH server";
    pubKey = mkStrOpt "" "Host public key";
  };

  config = {
    assertions = [
      {
        assertion = cfg.pubKey != "";
        message = "Please provide the host's SSH public key for use with agenix";
      }
    ];

    age.secrets."ssh_${config.${namespace}.user.name}".rekeyFile =
      ../../../../secrets/ssh/${hostName}.age;

    programs.ssh = {
      startAgent = true;
      enableAskPassword = true;
      askPassword = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
    };

    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        AllowUsers = [ config.${namespace}.user.name ];
      };
      authorizedKeysInHomedir = false;
      knownHosts = {
        "spoonbill" = {
          hostNames = [
            "spoonbill.internal"
            "10.0.1.2"
          ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINLhv0WaxWuQhBb3BG4wrebkb+egB2hdeysbODTGXSSQ";
        };

        "weebill" = {
          hostNames = [
            "weebill.internal"
            "10.0.1.3"
          ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMOltBRuLQ7MOZK8T1aYUKdBHXcshNPv+/EMoC7lXsE7";
        };

        "musk-duck" = {
          hostNames = [
            "musk-duck.internal"
            "10.0.1.10"
          ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICEp5zVloqXFtLEVCl44MwvdkfzIL4MsLqmENXjgPfnQ";
        };

        "pardalote" = {
          hostNames = [
            "pardalote.internal"
            "10.0.1.12"
          ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICEp5zVloqXFtLEVCl44MwvdkfzIL4MsLqmENXjgPfnQ";
        };

        "github" = {
          hostNames = [ "github.com" ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
        };
      };
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };
  };
}
