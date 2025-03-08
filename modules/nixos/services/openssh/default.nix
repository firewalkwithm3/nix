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
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };
  };
}
