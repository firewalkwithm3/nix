{ pkgs, config, yubikey, ... }:
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
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Authorised SSH keys
  users.users.fern.openssh.authorizedKeys.keys = [ yubikey.pubKey ];

  # Private key
  age.secrets."ssh_${hostName}".rekeyFile = ../../../secrets/ssh/${hostName}.age;
}
