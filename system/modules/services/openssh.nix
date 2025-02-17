{ pkgs, ... }:
{
  # SSH agent
  programs.ssh = {
    startAgent = true;
    enableAskPassword = true;
    askPassword = "${pkgs.gnome.seahorse}/libexec/seahorse/ssh-askpass";
  };

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
}
