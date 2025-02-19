{
  pkgs,
  config,
  yubikey,
  hosts,
  ...
}:
let
  hostName = config.networking.hostName;
in
{
  # SSH agent
  programs.ssh = {
    startAgent = true;
    enableAskPassword = true;
    askPassword = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
  };

  # Enable sudo on remote host with ssh key
  security.pam = {
    rssh.enable = true;
    services.sudo.rssh = true;
  };

  # SSH server
  services.openssh = {
    enable = true;
    knownHosts = {
      "garden" = {
        publicKey = hosts.garden.pubKey;
        hostNames = [ "garden.internal" ];
      };
      "leaf" = {
        publicKey = hosts.leaf.pubKey;
        hostNames = [ "leaf.internal" ];
      };
      "forest" = {
        publicKey = hosts.forest.pubKey;
        hostNames = [ "forest.internal" ];
      };
    };
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  # Authorised SSH keys
  users.users.fern.openssh.authorizedKeys.keys = [ yubikey.pubKey ];

  # Private key
  age.secrets."ssh_${hostName}".rekeyFile = ../../../secrets/ssh/${hostName}.age;
}
