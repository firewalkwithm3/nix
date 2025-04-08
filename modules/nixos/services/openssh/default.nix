{
  inputs,
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
  hosts = builtins.attrNames inputs.self.nixosConfigurations;
in
{
  options.${namespace}.services.openssh = with types; {
    enable = mkBoolOpt true "Enable SSH server";
    pubKey = mkStrOpt "" "Host public key";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.pubKey != "";
          message = "Please provide the host's SSH public key";
        }
      ];

      age.secrets."ssh_${hostName}".rekeyFile = (inputs.self + "/secrets/ssh/${hostName}.age");

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
        knownHosts =
          let
            hostNames = host: {
              hostNames = [ host ];
              publicKey = inputs.self.nixosConfigurations.${host}.config.flock.services.openssh.pubKey;
            };
          in
          flip genAttrs hostNames hosts;
        hostKeys = [
          {
            path = "/etc/ssh/ssh_host_ed25519_key";
            type = "ed25519";
          }
        ];
      };
    }

    (mkIf config.${namespace}.user.users.borg.enable {
      services.openssh.settings.AllowUsers = [ "borg" ];
    })
  ]);
}
