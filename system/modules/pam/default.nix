{ config, lib, ... }:
{
  imports = [ ./opts.nix ];

  # Global yubikey options
  age.secrets.u2f_keys = {
    rekeyFile = ../../../secrets/u2f_keys.age;
    owner = "fern";
  };

  security.pam.u2f = {
    settings = {
      cue = true;
      authfile = config.age.secrets.u2f_keys.path;
      origin = "fern";
    };
  };

  # PAM rules
  security.pam = {
    # Enable ssh-agent auth on forest
    rssh.enable = lib.mkIf (config.networking.hostName == "forest") true;
    services = {
      # Enable rssh auth for sudo on forest
      sudo.rssh = lib.mkIf (config.networking.hostName == "forest") true;
      sudo.rules.auth = {
        # Prefer yubikey first
        u2f.order = lib.mkForce (config.security.pam.services.sudo.rules.auth.unix.order - 10);
      };
      gtklock.rules.auth = {
        # gtklock doesn't support fido2 pin
        u2f.args = lib.mkForce [
          "pinverification=0"
          "userpresence=1"
        ];
      };
    };
  };
}
